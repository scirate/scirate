# == Schema Information
#
# Table name: papers
#
#  id              :integer          not null, primary key
#  uid             :text             not null
#  submitter       :text
#  title           :text             not null
#  abstract        :text             not null
#  author_comments :text
#  msc_class       :text
#  report_no       :text
#  journal_ref     :text
#  doi             :text
#  proxy           :text
#  license         :text
#  submit_date     :datetime         not null
#  update_date     :datetime         not null
#  abs_url         :text             not null
#  pdf_url         :text             not null
#  created_at      :datetime
#  updated_at      :datetime
#  scites_count    :integer          default(0), not null
#  comments_count  :integer          default(0), not null
#  pubdate         :datetime
#  author_str      :text             not null
#  versions_count  :integer          default(1), not null
#

class Paper < ActiveRecord::Base
  has_many  :versions, -> { order("position ASC") }, dependent: :delete_all,
            foreign_key: :paper_uid, primary_key: :uid
  has_many  :categories, -> { order("categories.position ASC") }, dependent: :delete_all,
            foreign_key: :paper_uid, primary_key: :uid
  has_many  :authors, -> { order("position ASC") }, dependent: :delete_all,
            foreign_key: :paper_uid, primary_key: :uid

  has_many :authorships, dependent: :destroy,
            foreign_key: :paper_uid, primary_key: :uid
  has_many :claimants, through: :authorships, source: :user

  has_many  :feeds, through: :categories

  has_many  :scites, dependent: :delete_all,
            foreign_key: :paper_uid, primary_key: :uid
  has_many  :sciters, -> { order("fullname ASC") }, through: :scites, source: :user
  has_many  :comments, -> { order("created_at ASC") }, dependent: :delete_all,
            foreign_key: :paper_uid, primary_key: :uid

  validates :uid, presence: true, uniqueness: true
  validates :title, presence: true
  validates :abstract, presence: true
  validates :abs_url, presence: true
  validates :submit_date, presence: true
  validates :update_date, presence: true

  validate :update_date_is_after_submit_date

  # Re-index after a scite or comment
  after_save do
    if scites_count_changed? || comments_count_changed?
      ::Search::Paper.index(self)
    end
  end

  # Given when a paper was submitted, estimate the
  # time at which the arXiv was likely to have published it
  def self.estimate_pubdate(submit_date)
    submit_date = submit_date.in_time_zone('EST')
    pubdate = submit_date.dup.change(hour: 20)

    # Weekend submissions => Monday
    if [6,0].include?(submit_date.wday)
      pubdate += 1.days if submit_date.wday == 0
      pubdate += 2.days if submit_date.wday == 6
    else
      if submit_date.wday == 5
        pubdate += 2.days # Friday submissions => Sunday
      end

      if submit_date.hour >= 16 # Past submission deadline
        pubdate += 1.day
      end
    end

    pubdate.utc
  end

  def refresh_comments_count!
    self.comments_count = Comment.where(
      paper_uid: uid,
      deleted: false,
      hidden: false
    ).count

    save!
  end

  def refresh_scites_count!
    self.scites_count = Scite.where(paper_uid: uid).count
    save!
  end

  def refresh_versions_count!
    self.versions_count = Version.where(paper_uid: uid).count
    save!
  end

  def to_param
    uid
  end

  def updated?
    update_date > submit_date
  end

  def to_bibtex
    props = {
      author: author_str.gsub(/\. /, ".~"), # unbreakable space
      title: title.gsub(/([A-Z]+)/, "{\\1}"),
      year: pubdate.year,
      eprint: uid
    }

    props[:howpublished] = journal_ref unless journal_ref.nil?
    props[:doi] = doi unless doi.nil?
    props[:note] = "arXiv:#{uid}v#{versions_count}"

    props = props.map { |k,v| "#{k} = {#{v}}" }

    %Q{@misc{#{uid},
  #{props.join(",\n  ")}
}}
  end

  # For compatibility with search document papers
  attr_accessor :authors_fullname, :authors_searchterm, :feed_uids

  def authors_fullname
    @authors_fullname ||= authors.map(&:fullname)
  end

  def authors_searchterm
    @authors_searchterm ||= authors.map(&:searchterm)
  end

  def feed_uids
    @feed_uids ||= categories.map(&:feed_uid)
  end

  private
    def update_date_is_after_submit_date
      return unless submit_date and update_date

      if update_date < submit_date
        errors.add(:update_date, "must not be earlier than submit_date")
      end
    end
end

# HACK (Mispy): Rails 3.2 changed to uri encode slashes in the
# output of to_param before constructing a path. Legacy arxiv
# paper ids contain a slash and we don't want to have to special
# case path generation all over the place, so ... this.

Rails.application.routes.url_helpers.send(
  :alias_method, :orig_paper_path, :paper_path
)

Rails.application.routes.url_helpers.send(
  :define_method, :paper_path, proc { |paper|
    orig_paper_path(paper).gsub("%2F", '/')
  }
)
