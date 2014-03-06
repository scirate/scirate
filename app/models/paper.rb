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

  validate :update_date_is_after_submit_date

  after_save do
    ::Search::Paper.index(self)
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

    save
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
  attr_accessor :query, :basic, :advanced
  attr_accessor :conditions, :feed, :authors, :order, :order_sql

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

  # Strip field prefix
  def tstrip(term)
    ['au:','ti:','abs:','in:','order:','date:'].each do |prefix|
      term = term.split(':', 2)[1] if term.start_with?(prefix)
    end

    #if term[0] == '(' && term[-1] == ')'
    #  term[1..-2]
    #else
    term
    #end
  end

  def parse_date(term)
    if term.match(/^\d\d\d\d$/)
      Chronic.parse(term+'-01-01')
    elsif term.match(/^\d\d\d\d-\d\d$/)
      Chronic.parse(term+'-01')
    else
      Chronic.parse(term)
    end
  end

  def parse_date_range(term)
    if term.include?('..')
      first, last = term.split('..').map { |t| parse_date(t) }
      first ||= 1000.years.ago
      last ||= Time.now
      first..last
    else
      # Allow implicit ranges like date:2012
      time = parse_date(term)
      if term.match(/^\d\d\d\d$/)
        time.beginning_of_year..time.end_of_year
      elsif term.match(/^\d\d\d\d-\d\d$/)
        time.beginning_of_month..time.end_of_month
      else
        time.beginning_of_day..time.end_of_day
      end
    end
  end

  def initialize(basic, advanced)
    @basic = basic
    @advanced = advanced

    @query = [@basic, @advanced].join(' ').strip

    @general = nil # Term to apply as OR across all text fields
    @conditions = {}
    @authors = []
    @date_range = nil
    @orders = []

    psplit(@query).each do |term|
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
        @conditions[:title] ||= []
        @conditions[:title] << tstrip(term)
      elsif term.start_with?('abs:')
        @conditions[:abstract] ||= []
        @conditions[:abstract] << tstrip(term)
      elsif term.start_with?('in:')
        @conditions[:feed_uids] ||= []
        @conditions[:feed_uids] << tstrip(term)
      elsif term.start_with?('order:')
        @orders << tstrip(term).to_sym
      elsif term.start_with?('date:')
        @date_range = parse_date_range(tstrip(term))
      else
        if @general
          @general += ' ' + term
        else
          @general = term
        end
      end
    end

    @sort = []

    @orders = [:scites] if @orders.empty?

    @orders.each do |order|
      case order
      when :scites then @sort << { scites_count: 'desc' }
      when :comments then @sort << { comments_count: 'desc' }
      when :recency then @sort << { pubdate: 'desc' }
      when :relevancy then nil # Standard text match sort
      end
    end

    # Everything is post-sorted by pubdate except :relevancy
    unless @sort.empty? || @orders.include?(:recency)
      @sort << { pubdate: 'desc' }
    end
  end

  def run(opts={})
    es_query = []
    es_query << @general unless @general.nil?
    @conditions.each do |cond, vals|
      vals.each do |val|
        es_query << "#{cond}:#{val}"
      end
    end

    p es_query.join(' ')

    filter = if @date_range
      {
        range: {
          pubdate: {
            from: @date_range.first,
            to: @date_range.last
          }
        }
      }
    else
      nil
    end

    params = {
      sort: @sort,
      query: {
        filtered: {
          query: {
            query_string: {
              query: es_query.join(' '),
              default_operator: 'AND'
            }
          },
          filter: filter
        }
      }
    }.merge(opts)

    @results = ::Search::Paper.find(params)
  end
end

