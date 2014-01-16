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
#  submit_date        :date
#  update_date   :date
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
  validates :submit_date, presence: true
  validates :update_date, presence: true
  validates :feed_id, presence: true

  validate  :update_date_is_after_submit_date

  after_create { cross_list_primary_feed }

  # Returns papers from feeds subscribed to by the given user
  scope :from_feeds_subscribed_by, lambda { |user| subscribed_by(user) }
  scope :from_feeds_subscribed_by_cl, lambda { |user| subscribed_by_cl(user) }

  # Returns a paginated selection of papers based on
  # a date, a number of days into the past to look, and
  # an optional page index
  def self.range_query(papers, date, range=0, page=nil)
    papers = papers.includes(:feed, :authors, :cross_lists => :feed)
    papers = papers.where("submit_date >= ? AND submit_date <= ?", date - range.days, date)
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

    updated_ids = []

    paper_columns = [:identifier, :submitter, :title, :abstract, :comments, :msc_class, :report_no, :journal_ref, :doi, :proxy, :license, :submit_date, :update_date, :abs_url, :pdf_url]
    paper_values = []

    relevant_models = []

    models.each do |model|
      existing = existing_by_ident[model.id]

      if existing
        if existing.update_date >= model.versions[-1].date
          next # Already up to date
        else
          updated_ids << existing.id
        end
      end

      paper_values << [
        model.id,
        model.submitter,
        model.title,
        model.abstract,
        model.comments,
        model.msc_class,
        model.report_no,
        model.journal_ref,
        model.doi,
        model.proxy,
        model.license,

        model.versions[0].date,
        model.versions[-1].date,
        "http://arxiv.org/abs/#{model.id}",
        "http://arxiv.org/pdf/#{model.id}.pdf",
      ]

      relevant_models << model
    end

    Arxiv::Paper.where(id: updated_ids).delete_all

    puts "Read #{models.length} items: #{paper_values.length-updated_ids.length} new, #{updated_ids.length} updated [#{models[0].id} to #{models[-1].id}]"
    result = Arxiv::Paper.import(paper_columns, paper_values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing papers: #{result.failed_instances.inspect}")
    end

    relevant_idents = paper_values.map { |val| val[0] }
    relevant_ids = Paper.where(identifier: relevant_idents).pluck(:id).sort

    version_columns = [:paper_id, :position, :date, :size]
    version_values = []

    author_columns = [:paper_id, :position, :fullname, :searchterm]
    author_values = []

    category_columns = [:paper_id, :position, :category]
    category_values = []

    relevant_models.each_with_index do |model, i|
      paper_id = paper_ids[i]

      model.versions.each_with_index do |version, j|
        version_values << [
          paper_id,
          j,
          version.date,
          version.size
        ]
      end

      model.authors.each_with_index do |author, j|
        author_values << [
          paper_id,
          j,
          author,
          Author.make_searchterm(author)
        ]
      end

      model.categories.each_with_index do |category, j|
        category_values << [
          paper_id,
          j,
          category
        ]
      end
    end

    puts "Importing #{version_values.length} versions" unless version_values.empty?
    result = Arxiv::Version.import(version_columns, version_values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing versions #{result.failed_instances.inspect}")
    end

    puts "Importing #{author_values.length} authors" unless author_values.empty?
    result = Arxiv::Author.import(author_columns, author_values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing authors: #{result.failed_instances.inspect}")
    end

    puts "Importing #{category_values.length} categories" unless category_values.empty?
    result = Arxiv::Category.import(category_columns, category_values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing categories: #{result.failed_instances.inspect}")
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
    update_date > submit_date
  end

  private

    def cross_list_primary_feed
      self.cross_lists.create(feed_id: self.feed.id, \
                              cross_list_date: self.submit_date)
    end

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

