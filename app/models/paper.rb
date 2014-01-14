# == Schema Information
#
# Table name: papers
#
#  id             :integer          not null, primary key
#  title          :text
#  authors        :text
#  abstract       :text
#  identifier     :string(255)
#  url            :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  pubdate        :date
#  updated_date   :date
#  scites_count   :integer          default(0)
#  comments_count :integer          default(0)
#  feed_id        :integer
#  pdf_url        :string(255)
#  author_str     :text
#  delta          :boolean          default(TRUE), not null
#

class Paper < ActiveRecord::Base
  belongs_to :feed

  has_many  :scites, dependent: :destroy
  has_many  :sciters, -> { order("name ASC") }, through: :scites
  has_many  :comments, -> { order("created_at ASC") }, dependent: :destroy
  has_many  :cross_lists, dependent: :destroy
  has_many  :cross_listed_feeds, -> { order("name ASC") }, through: :cross_lists, \
                source: :feed
  has_many :authors, -> { order(:position) }, class_name: "Authorship"

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

    ### Second pass: Add new papers and handle updates.

    # Need to find and update existing papers, then bulk import new ones
    identifiers = models.map(&:id)
    existing_papers = Paper.where(identifier: identifiers)
    existing_by_ident = Hash[existing_papers.map { |paper| [paper.identifier, paper] }]

    columns = [:identifier, :feed_id, :url, :pdf_url, :title, :abstract, :pubdate, :updated_date]
    values = []
    updated_papers = []

    models.each do |model|
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
          model.updated || model.created
        ]
      end
    end

    puts "Read #{models.length} items: #{values.length} new, #{updated_papers.length} updated [#{models[0].id} to #{models[-1].id}]"
    result = Paper.import(columns, values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing papers: #{result.failed_instances.inspect}")
    end

    #return if values.empty? && updated_papers.empty? # Skip the rest if no new data

    ### Third pass: Add authorships, deleting any existing ones first.

    relevant_idents = updated_papers.map(&:identifier)+values.map { |val| val[0] }
    relevant_papers = Paper.where(identifier: relevant_idents)
    papers_by_ident = Hash[relevant_papers.map { |paper| [paper.identifier, paper] }]
    paper_ids = papers_by_ident.values.map(&:id)

    Authorship.where(paper_id: paper_ids).delete_all

    author_columns = [:paper_id, :affiliation, :forenames, :keyname, :suffix, :fullname, :searchterm, :position]
    author_values = []


    models.each do |model|
      next unless papers_by_ident[model.id]

      position = 0
      model.authors.each do |author|
        author_values << [
          papers_by_ident[model.id],
          author.affiliation,
          author.forenames,
          author.keyname,
          author.suffix,
          Authorship.make_fullname(author),
          Authorship.make_searchterm(author),
          position
        ]
        position += 1
      end
    end

    puts "Importing #{author_values.length} authorships" unless author_values.empty?
    result = Authorship.import(author_columns, author_values, opts)
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

    # Return the papers we imported/updated
    relevant_papers
  end

  def self.arxiv_import(models, opts={})
    papers = []

    # Pause sphinx delta updates so we can do it all
    # in one batch after the import
    ThinkingSphinx::Deltas.suspend :paper do
      transaction do
        papers = self._arxiv_import(models, opts)
      end
    end

    papers
  end

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

