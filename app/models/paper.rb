# == Schema Information
#
# Table name: papers
#
#  id             :integer          not null, primary key
#  uid            :string(255)      not null
#  submitter      :string(255)      not null
#  title          :string(255)      not null
#  abstract       :text             not null
#  comments       :text
#  msc_class      :string(255)
#  report_no      :string(255)
#  journal_ref    :string(255)
#  doi            :string(255)
#  proxy          :string(255)
#  license        :string(255)
#  submit_date    :datetime         not null
#  update_date    :datetime         not null
#  abs_url        :string(255)      not null
#  pdf_url        :string(255)      not null
#  delta          :boolean          default(TRUE), not null
#  created_at     :datetime
#  updated_at     :datetime
#  scites_count   :integer          default(0), not null
#  comments_count :integer          default(0), not null
#

class Paper < ActiveRecord::Base
  has_many  :versions, -> { order("position ASC") }, dependent: :destroy,
            foreign_key: :paper_uid, primary_key: :uid
  has_many  :categories, -> { order("position ASC") }, dependent: :destroy,
            foreign_key: :paper_uid, primary_key: :uid
  has_many  :authors, -> { order("position ASC") }, dependent: :destroy,
            foreign_key: :paper_uid, primary_key: :uid
            

  has_many  :scites, dependent: :destroy
  has_many  :sciters, -> { order("fullname ASC") }, through: :scites, source: :user
  has_many  :comments, -> { order("created_at ASC") }, dependent: :destroy
  has_many  :feeds, -> { order("categories.position ASC") }, through: :categories

  validates :uid, presence: true, uniqueness: true
  validates :title, presence: true
  validates :abstract, presence: true
  validates :abs_url, presence: true
  validates :submit_date, presence: true
  validates :update_date, presence: true

  validate  :update_date_is_after_submit_date

  # Returns papers from feeds subscribed to by the given user
  scope :from_feeds_subscribed_by, lambda { |user| subscribed_by(user) }
  scope :from_feeds_subscribed_by_cl, lambda { |user| subscribed_by_cl(user) }

  # Returns a paginated selection of papers based on
  # a date, a number of days into the past to look, and
  # an optional page index
  def self.range_query(papers, date, range=0, page=nil)
    papers = papers.includes(:feed, :authors, :cross_lists => :feed)
    papers = papers.where("submit_date >= ? AND submit_date <= ?", date - range.days, date)
    papers = papers.order("scites_count DESC, comments_count DESC, uid ASC")
    papers = papers.limit(30)
    papers
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

    # Returns SQL condition for papers from feeds subscribed
    # to by the given user.
    def self.subscribed_by(user)
      subscribed_ids = %(SELECT feed_id FROM subscriptions
                         WHERE user_id = ?)
      where("feed_id IN (#{subscribed_ids})", user.id)
    end

    def self.subscribed_by_cl(user)
      subscribed_ids = %(SELECT feed_id FROM subscriptions
                         WHERE user_id = ?)
      includes(:cross_lists).where("cross_lists.feed_id IN (#{subscribed_ids})", user.id)
    end
end

class Paper::Search
  attr_reader :results
  attr_accessor :conditions, :general_term, :feed, :authors

  # Split string on spaces which aren't enclosed by quotes
  def qsplit(query)
    q = query.dup
    quoted = false
    indices = []
    q.chars.each_with_index do |ch, i|
      quoted = !quoted if ch == '"'
      indices << i if ch == ' ' && !quoted
    end
    indices.each { |i| q[i] = "\x00" }
    q.split("\x00")
  end

  # Strip field prefix and quotes
  def tstrip(term)
    ['au:','ti:','abs:','feed:'].each do |prefix|
      term = term.split(':', 2)[1] if term.start_with?(prefix)
    end
    term#.gsub("'", "''").gsub('"', "'")
  end

  def initialize(query)
    @general_term = nil # Term to apply as OR across all text fields

    @conditions = {}

    @feed = nil
    @authors = []
    @arxivstyle_authors = []

    qsplit(query).each do |term|
      if term.start_with?('au:')
        if term.include?('_')
          @conditions[:authors_searchterm] ||= []
          @conditions[:authors_searchterm] << tstrip(term)
        else
          @conditions[:authors_fullname] ||= []
          @conditions[:authors_fullname] << tstrip(term)
        end
      elsif term.start_with?('ti:')
        @conditions[:title] = tstrip(term)
      elsif term.start_with?('abs:')
        @conditions[:abstract] = tstrip(term)
      elsif term.start_with?('feed:')
        @feed = Feed.find_by_name(tstrip(term))
      else
        if @general_term
          @general_term += ' ' + term
        else
          @general_term = term
        end
      end
    end
  end

  def run(opts={})
    params = { conditions: @conditions }
    params[:with] = { feed_ids: @feed.id } unless @feed.nil?
    params = params.merge(opts)
    @results = Paper.search_for_ids(@general_term, params)
  end
end

