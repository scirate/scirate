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
  attr_accessible :title, :authors, :abstract, :identifier, :url, :pubdate, :updated_date
  serialize :authors, Array

  belongs_to :feed

  has_many  :scites, dependent: :destroy
  has_many  :sciters, through: :scites, order: "name ASC"
  has_many  :comments, dependent: :destroy, order: "created_at ASC"
  has_many  :cross_lists, dependent: :destroy
  has_many  :cross_listed_feeds, through: :cross_lists, \
                source: :feed, order: "name ASC"

  validates :title, presence: true
  validates :authors, presence: true
  validates :abstract, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :url, presence: true
  validates :pubdate, presence: true
  validates :updated_date, presence: true
  validates :feed, presence: true

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

  def self.arxivsync_import(models)
    ### First pass: Create any new feeds.

    existing_feednames = Feed.all.map(&:name)

    feednames = models.map { |model| 
      [model.primary_category]+model.crosslists 
    }.flatten.uniq
    new_feednames = feednames - existing_feednames

    new_feednames.each do |feedname|
      puts "Discovered new feed: #{feedname}"
      Feed.create!(
        name: feedname,
        url: "http://export.arxiv.org/rss/#{feedname}",
        feed_type: "arxiv"
      )
    end

    feeds_by_name = Feed.map_names

    ### Second pass: Add any new papers.
    
    # Need to find and update existing papers, then bulk import new ones
    identifiers = models.map(&:id)
    existing_papers = Paper.find_all_by_identifier(identifiers)
    existing_by_ident = Hash[existing_papers.map { |paper| [paper.identifier, paper] }]

    new_papers = []
    updated_papers = []
    models.each do |model|
      if existing_by_ident.has_key?(model.id)
        paper = existing_by_ident[model.id]
        next if paper.updated_date >= (model.updated || model.created) # No new content
      else
        paper = Paper.new
      end

      paper.identifier = model.id
      paper.feed_id = feeds_by_name[model.primary_category].id
      paper.url = "http://arxiv.org/abs/#{model.id}"
      paper.pdf_url = "http://arxiv.org/pdf/#{model.id}.pdf"
      paper.title = model.title
      paper.abstract = model.abstract
      paper.pubdate = model.created
      paper.updated_date = model.updated || model.created
      paper.authors = model.authors

      begin
        if existing_by_ident.has_key?(model.id)
          updated_papers.push(paper)
          paper.save!
        else
          new_papers.push(paper)
          paper.save!
        end
      rescue
        puts "Error importing: #{model.id}"
        raise
      end
    end

    #Paper.import(new_papers).failed_instances
    puts "Read #{models.length} items: #{new_papers.length} new, #{updated_papers.length} updated [#{models[0].id} to #{models[-1].id}]"
    
    relevant_papers = new_papers+updated_papers
    return if relevant_papers.empty? # Skip the rest if we found no new data

    ### Finally: crosslists!
    papers_by_ident = Hash[relevant_papers.map { |paper| [paper.identifier, paper] }]
    paper_ids = papers_by_ident.values.map(&:id)
    existing_crosslists = CrossList.find_all_by_paper_id(paper_ids).map { |cl| [cl.paper_id, cl.feed_id] }
    
    new_crosslists = []
    models.each do |model|
      next unless papers_by_ident.has_key?(model.id)
      paper_id = papers_by_ident[model.id].id
      model.crosslists.each do |feedname|
        feed_id = feeds_by_name[feedname].id
        next if existing_crosslists.include?([paper_id, feed_id])
        crosslist = CrossList.new
        crosslist.paper_id = paper_id
        crosslist.feed_id = feed_id
        crosslist.cross_list_date = model.created
        new_crosslists.push(crosslist)
      end
    end

    #puts "Importing #{new_crosslists.length} crosslists..." unless new_crosslists.empty?
    CrossList.import(new_crosslists)

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
