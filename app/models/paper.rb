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
#  delta           :boolean          default(TRUE), not null
#  created_at      :datetime
#  updated_at      :datetime
#  scites_count    :integer          default(0), not null
#  comments_count  :integer          default(0), not null
#  pubdate         :datetime
#  author_str      :text             not null
#

class Paper < ActiveRecord::Base
  has_many  :versions, -> { order("position ASC") }, dependent: :delete_all,
            foreign_key: :paper_uid, primary_key: :uid
  has_many  :categories, -> { order("position ASC") }, dependent: :delete_all,
            foreign_key: :paper_uid, primary_key: :uid
  has_many  :authors, -> { order("position ASC") }, dependent: :delete_all,
            foreign_key: :paper_uid, primary_key: :uid

  has_many  :feeds, -> { order("categories.position ASC") }, through: :categories

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

  validate  :update_date_is_after_submit_date

  # Given when a paper was submitted, estimate the
  # time at which the arXiv was likely to have published it
  def self.estimate_pubdate(submit_date)
    pubdate = submit_date.dup.change(hour: 1)

    # Weekend submissions => Tuesday
    if [6,0].include?(submit_date.wday)
      pubdate += 2.days if submit_date.wday == 0
      pubdate += 3.days if submit_date.wday == 6
    else
      if submit_date.wday == 5
        pubdate += 3.days # Friday submissions => Monday
      else
        pubdate += 1.day # Otherwise => next day
      end

      if submit_date.hour >= 21 # Past submission deadline
        pubdate += 1.day
      end
    end

    pubdate
  end


  def to_param
    uid
  end

  def updated?
    update_date > submit_date
  end

  private
    def update_date_is_after_submit_date
      return unless submit_date and update_date

      if update_date < submit_date
        errors.add(:update_date, "must not be earlier than submit_date")
      end
    end
end

class Paper::Search
  attr_reader :results
  attr_accessor :conditions, :query, :advanced, :feed, :authors, :order, :order_sql

  # Split query on non-paren enclosed spaces
  def psplit(query)
    split = []
    depth = 0
    current = ""

    query.chars.each_with_index do |ch, i|
      if i == query.length-1
        split << current+ch
      elsif ch == ' ' && depth == 0
        split << current
        current = ""
      else
        current << ch

        if ch == '('
          depth += 1
        elsif ch == ')'
          depth -= 1
        end
      end
    end

    split
  end

  # Strip field prefix and parens
  def tstrip(term)
    ['au:','ti:','abs:','feed:','order:'].each do |prefix|
      term = term.split(':', 2)[1] if term.start_with?(prefix)
    end

    if term[0] == '(' && term[-1] == ')'
      term[1..-2]
    else
      term
    end
  end

  def initialize(query)
    @query = nil # Term to apply as OR across all text fields

    @conditions = {}

    @feed = nil
    @authors = []
    @order = :scites

    psplit(query).each do |term|
      if term.start_with?('au:')
        if term.include?('_')
          @authors << tstrip(term)
          @conditions[:authors_searchterm] ||= []
          @conditions[:authors_searchterm] << tstrip(term)
        else
          @authors << tstrip(term)
          @conditions[:authors_fullname] ||= []
          @conditions[:authors_fullname] << tstrip(term)
        end
      elsif term.start_with?('ti:')
        @conditions[:title] = tstrip(term)
      elsif term.start_with?('abs:')
        @conditions[:abstract] = tstrip(term)
      elsif term.start_with?('feed:')
        @feed = Feed.find_by_uid(tstrip(term))
        @conditions[:feed_uids] = @feed.uid
      elsif term.start_with?('order:')
        @order = tstrip(term).to_sym
      else
        if @query
          @query += ' ' + term
        else
          @query = term
        end
      end
    end

    @order_sql = case @order
                 when :scites then "scites_count DESC, pubdate DESC"
                 when :comments then "comments_count DESC, pubdate DESC"
                 when :recency then "pubdate DESC"
                 when :relevancy then nil # Default Sphinx match relevancy
                 end
  end

  def run(opts={})
    params = {}
    params[:conditions] = @conditions
    params[:order] = @order_sql unless @order_sql.nil?

    params = params.merge(opts)
    @results = Paper.search_for_ids(@query, params)
  end
end

