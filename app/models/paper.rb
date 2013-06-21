# == Schema Information
#
# Table name: papers
#
#  id             :integer         primary key
#  title          :text
#  authors        :text
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
  attr_accessible :title, :abstract, :identifier, :url, :pubdate, :updated_date

  belongs_to :feed

  has_many  :scites, dependent: :destroy
  has_many  :sciters, through: :scites, order: "name ASC"
  has_many  :comments, dependent: :destroy, order: "created_at ASC"
  has_many  :cross_lists, dependent: :destroy
  has_many  :cross_listed_feeds, through: :cross_lists, \
                source: :feed, order: "name ASC"
  has_many :authorships
  has_many :authors, :through => :authorships

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

  def author_names
    authors.map { |author| 
      if author.forenames
        author.forenames + ' ' + author.keyname 
      else
        author.keyname
      end
    }
  end

  def self.arxiv_import(models, opts={})
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
    existing_papers = Paper.find_all_by_identifier(identifiers)
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
        updates_papers.push(paper)
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

    result = Paper.import(columns, values, opts)
    unless result.failed_instances.empty?
      Scirate3.notify_error("Error importing papers: #{result.failed_instances.inspect}")
    end
    puts "Read #{models.length} items: #{values.length} new, #{updated_papers.length} updated [#{models[0].id} to #{models[-1].id}]"

    return if values.empty? && updated_papers.empty? # Skip the rest if no new data

    relevant_papers = Paper.find_all_by_identifier(identifiers)
    

    ### Fourth pass: Add any new authorships.
    authors = Author.find_all_by_uniqid(author_models.map { |model| Author.make_uniqid(model) })
    authors_by_uniqid = Hash[authors.map { |author| [author.uniqid, author] }]
    papers_by_ident = Hash[relevant_papers.map { |paper| [paper.identifier, paper] }]
    paper_ids = papers_by_ident.values.map(&:id)
    existing_authorships = Authorship.find_all_by_paper_id(paper_ids).map { |au| [au.paper_id, au.author_id] }

    columns = [:paper_id, :author_id]
    values = []
    models.each do |model|
      next unless papers_by_ident.has_key?(model.id)
      paper_id = papers_by_ident[model.id].id
      model.authors.each do |author|
        author_id = authors_by_uniqid[Author.make_uniqid(author)]
        next if existing_authorships.include?([author_id, paper_id])
        values << [paper_id, author_id]
      end
    end

    result = Authorship.import(columns, values, opts)
    unless result.failed_instances.empty?
      Scirate3.notify_error("Error importing authorships: #{result.failed_instances.inspect}")
    end
    puts "Imported #{values.length} authorships" unless values.empty?

    ### Finally: crosslists!
    existing_crosslists = CrossList.find_all_by_paper_id(paper_ids).map { |cl| [cl.paper_id, cl.feed_id] }
    
    columns = [:paper_id, :feed_id, :cross_list_date]
    values = []
    models.each do |model|
      next unless papers_by_ident.has_key?(model.id)
      paper_id = papers_by_ident[model.id].id
      model.crosslists.each do |feedname|
        feed_id = feeds_by_name[feedname].id
        next if existing_crosslists.include?([paper_id, feed_id])
        values << [paper_id, feed_id, model.created]
      end
    end

    result = CrossList.import(columns, values, opts)
    unless result.failed_instances.empty?
      Scirate3.notify_error("Error importing crosslists: #{result.failed_instances.inspect}")
    end
    puts "Imported #{values.length} crosslists" unless values.empty?

    # Update last paper date for involved feeds
    feednames.each do |feedname|
      feeds_by_name[feedname].update_last_paper_date
    end
  end

  extend Searchable(:title, :authors)

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
