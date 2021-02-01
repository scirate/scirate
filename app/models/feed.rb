# == Schema Information
#
# Table name: feeds
#
#  id                  :integer          not null, primary key
#  uid                 :text             not null
#  source              :text             not null
#  fullname            :text             not null
#  position            :integer          default(0), not null
#  subscriptions_count :integer          default(0), not null
#  last_paper_date     :datetime
#  parent_uid          :text
#

class Feed < ActiveRecord::Base
  belongs_to :parent, foreign_key: :parent_uid,
             primary_key: :uid, class_name: "Feed"
  has_many :children, foreign_key: :parent_uid,
           primary_key: :uid, class_name: 'Feed'
  has_many :subscriptions, dependent: :destroy,
           foreign_key: :feed_uid, primary_key: :uid
  has_many :users, through: :subscriptions
  has_many :categories, dependent: :destroy,
           foreign_key: :feed_uid, primary_key: :uid
  has_many :papers, through: :categories, source: :paper

  validates :uid, presence: true, uniqueness: true
  validates :fullname, presence: true
  validates :source, presence: true

  # Returns toplevel arxiv categories for sidebar
  def self.arxiv_folders
    @@arxiv_folders ||= Feed.where(uid: Settings::ARXIV_FOLDERS).includes(:children).to_a
  end

  def self.arxiv_import(uids, opts={})
    existing = Feed.all.map(&:uid)

    columns = [:uid, :fullname, :source]
    values = []

    (uids - existing).map do |uid|
      logger.info "Discovered new feed: #{uid}"
      values << [
        uid,
        uid.to_s,
        "arxiv"
      ]
    end

    result = Feed.import(columns, values, opts)
    unless result.failed_instances.empty?
      SciRate::Application.notify_error("Error importing feeds: #{result.failed_instances.inspect}")
    end
  end

  def self.find_related_uids(uids)
    Rails.cache.fetch [:related_uids, uids] do
      uids + Feed.where(parent_uid: uids).pluck(:uid)
    end
  end

  # Grab a set of feeds in order by uid
  def self.in_order(uids)
    Feed.where(uid: uids).includes(:children).index_by(&:uid).slice(*uids).values
  end

  def to_param
    uid
  end

  # Update last_paper_date to the given timestamp if applicable
  # Also update parent
  def new_paper_date!(dt)
    if self.last_paper_date.nil? || dt.to_date > self.last_paper_date.to_date
      self.last_paper_date = dt
      self.save!

      unless self.parent_uid.nil?
        self.parent.new_paper_date!(dt)
      end
    end
  end

  def update_last_paper_date!
    uids = [self.uid] + self.children.pluck(:uid)
    category = Category.where(feed_uid: uids).order("crosslist_date ASC").last
    unless category.nil?
      self.last_paper_date = category.crosslist_date
      self.save!
    end
  end
end
