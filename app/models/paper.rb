# == Schema Information
#
# Table name: papers
#
#  id             :integer         primary key
#  title          :text
#  author_str     :text
#  abstract       :text
#  identifier     :string(255)
#  url            :string(255)
#  created_at     :timestamp       not null
#  updated_at     :timestamp       not null
#  pubdate        :date
#  updated_date   :date
#  scites_count   :integer         default(0)
#  comments_count :integer         default(0)
#  feed_id        :integer
#

require 'textacular/searchable'

class Paper < ActiveRecord::Base
  belongs_to :feed

  has_many  :scites, dependent: :destroy
  has_many  :sciters, -> { order("name ASC") }, through: :scites
  has_many  :comments, -> { order("created_at ASC") }, dependent: :destroy
  has_many  :cross_lists, dependent: :destroy
  has_many  :cross_listed_feeds, -> { order("name ASC") }, through: :cross_lists, \
                source: :feed
  has_many :authorships, -> { order(:position) }
  has_many :authors, -> { order('authorships.position') }, :through => :authorships

  validates :title, presence: true
  validates :abstract, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :url, presence: true
  validates :pubdate, presence: true
  validates :updated_date, presence: true
  validates :feed_id, presence: true

  validate  :updated_date_is_after_pubdate

  after_create { cross_list_primary_feed }

  # Returns papers from feeds subscribed to by the given user
  scope :from_feeds_subscribed_by, lambda { |user| subscribed_by(user) }
  scope :from_feeds_subscribed_by_cl, lambda { |user| subscribed_by_cl(user) }

  # Returns a paginated selection of papers based on
  # a date, a number of days into the past to look, and
  # an optional page index
  def self.range_query(papers, date, range=0, page=nil)
    papers = papers.includes(:feed, :authors, :cross_lists => :feed)
    papers = papers.where("pubdate >= ? AND pubdate <= ?", date - range.days, date)
    papers = papers.order("scites_count DESC, comments_count DESC, identifier ASC")
    papers = papers.limit(30)
    papers
  end

  def self._arxiv_import(models, opts={})
    ### First pass: Add new Feeds.
    feednames = models.map { |m| m.categories }.flatten.uniq
    Feed.arxiv_import(feednames, opts)
    feeds_by_name = Feed.map_names

    ### Second pass: Add new Authors.
    author_models = models.map(&:authors).flatten.uniq
    Author.arxiv_import(author_models, opts)

    ### Third pass: Add new papers and handle updates.
    
    # Need to find and update existing papers, then bulk import new ones
    identifiers = models.map(&:id)
    existing_papers = Paper.where(identifier: identifiers)
    existing_by_ident = Hash[existing_papers.map { |paper| [paper.identifier, paper] }]

    columns = [:identifier, :feed_id, :url, :pdf_url, :title, :abstract, :pubdate, :updated_date, :author_str]
    values = []
    updated_papers = []
    models.each do |model|
      author_str = model.authors.map { |au| Author.make_fullname(au) }.join(',')
      if (paper = existing_by_ident[model.id])
        next if paper.updated_date >= (model.updated || model.created) # No new content

        paper.identifier = model.id
        paper.feed_id = feeds_by_name[model.primary_category].id
        paper.url = "http://arxiv.org/abs/#{model.id}"
        paper.pdf_url = "http://arxiv.org/pdf/#{model.id}.pdf"
        paper.title = model.title
        paper.abstract = model.abstract
        paper.pubdate = model.created
        paper.updated_date = model.updated || model.created
        paper.author_str = author_str


        paper.save!
        updated_papers.push(paper)
      else
        values << [
          model.id,
          feeds_by_name[model.primary_category].id,
          "http://arxiv.org/abs/#{model.id}",
          "http://arxiv.org/pdf/#{model.id}.pdf",
          model.title,
          model.abstract,
          model.created,
          model.updated || model.created,
          author_str
        ]
      end
    end

    puts "Read #{models.length} items: #{values.length} new, #{updated_papers.length} updated [#{models[0].id} to #{models[-1].id}]"
    result = Paper.import(columns, values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing papers: #{result.failed_instances.inspect}")
    end

    #return if values.empty? && updated_papers.empty? # Skip the rest if no new data

    relevant_papers = Paper.where(identifier: identifiers)
    

    ### Fourth pass: Add any new authorships.
    authors = Author.where(uniqid: author_models.map { |model| Author.make_uniqid(model) })
    authors_by_uniqid = Hash[authors.map { |author| [author.uniqid, author] }]
    papers_by_ident = Hash[relevant_papers.map { |paper| [paper.identifier, paper] }]
    paper_ids = papers_by_ident.values.map(&:id)
    
    existing_authorships = Hash.new { |h,k| h[k] = [] }
    Authorship.where(paper_id: paper_ids).each do |au|
      existing_authorships[au.paper_id].push(au.author_id)
    end

    columns = [:paper_id, :author_id, :position]
    values = []
    models.each do |model|
      next unless papers_by_ident.has_key?(model.id)
      paper_id = papers_by_ident[model.id].id
      model.authors.each_with_index do |author, i|
        author_id = authors_by_uniqid[Author.make_uniqid(author)].id
        next if existing_authorships[paper_id].include?(author_id)
        values << [paper_id, author_id, i]
      end
    end

    puts "Importing #{values.length} authorships" unless values.empty?
    result = Authorship.import(columns, values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing authorships: #{result.failed_instances.inspect}")
    end

    ### Finally: crosslists!
    existing_crosslists = CrossList.where(paper_id: paper_ids).map { |cl| [cl.paper_id, cl.feed_id] }
    
    columns = [:paper_id, :feed_id, :cross_list_date]
    values = []
    models.each do |model|
      next unless papers_by_ident.has_key?(model.id)
      paper_id = papers_by_ident[model.id].id
      model.categories.each do |feedname|
        feed_id = feeds_by_name[feedname].id
        next if existing_crosslists.include?([paper_id, feed_id])
        values << [paper_id, feed_id, model.created]
      end
    end

    puts "Importing #{values.length} crosslists" unless values.empty?
    result = CrossList.import(columns, values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing crosslists: #{result.failed_instances.inspect}")
    end

    # Update last paper date for involved feeds
    feednames.each do |feedname|
      feeds_by_name[feedname].update_last_paper_date
    end
  end

  def self.arxiv_import(models, opts={})
    transaction do
      self._arxiv_import(models, opts)
    end
  end

  extend Searchable(:title, :abstract, :author_str)

  def to_param
    identifier
  end

  def updated?
    updated_date > pubdate
  end

  private

    def cross_list_primary_feed
      self.cross_lists.create(feed_id: self.feed.id, \
                              cross_list_date: self.pubdate)
    end

    def updated_date_is_after_pubdate
      return unless pubdate and updated_date

      if updated_date < pubdate
        errors.add(:updated_date, "must not be earlier than pubdate")
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
  attr_accessor :field_terms, :general_term, :feed, :authors

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
    @field_terms = {} # Terms for individual text fields
    @feed = nil
    @authors = []

    qsplit(query).each do |term|
      if term.start_with?('au:')
        @authors << tstrip(term)
        if @field_terms[:author_str]
          @field_terms[:author_str] = @field_terms[:author_str] + " & #{tstrip(term)}"
        else
          @field_terms[:author_str] = tstrip(term)
        end
      elsif term.start_with?('ti:')
        @field_terms[:title] = tstrip(term)
      elsif term.start_with?('abs:')
        @field_terms[:abstract] = tstrip(term)
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

    @results = Paper

    # Limit by feed
    if @feed
      feed_ids = [@feed.id] + @feed.children.pluck(:id)
      @results = @results.joins(:cross_lists).where(:cross_lists => { :feed_id => feed_ids })
    end

    @results = @results.advanced_search(@general_term) if @general_term
    @results = @results.advanced_search(@field_terms) unless @field_terms.empty?
  end

  def field_term(key, term, operator='&')
    if @field_terms[key]
      @field_terms[key] += " #{operator} #{term}"
    else
      @field_terms[key] = term
    end
  end
end

