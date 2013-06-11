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

  def self.arxivsync_import(models)
    ### First pass: Create any new feeds.

    existing_feeds = Feed.all.map(&:name)

    # Feeds to add as columns + values
    feed_columns = [:name, :url, :feed_type]
    feed_values = []

    models.each do |model|
      ([model.primary_category]+model.crosslists).each do |category|
        unless existing_feeds.include?(category)
          feed_values.push([
            category,
            "http://export.arxiv.org/rss/#{category}",
            "arxiv"
          ])
          existing_feeds.push(category)
        end
      end
    end

    puts "Importing #{feed_values.length} new feeds..." unless feed_values.empty?
    Feed.import(feed_columns, feed_values, validate: false)

    feeds_by_name = Feed.map_names

    ### Second pass: Add any new papers.

    identifiers = models.map(&:id)
    existing_papers = Paper.find_all_by_identifier(identifiers).map(&:identifier)

    # Papers to add as columns+values
    paper_columns = [:identifier, :feed_id, :url, :pdf_url, :title, :abstract, :pubdate, :updated_date, :authors]
    paper_values = []

    models.each do |model|
      next if existing_papers.include?(model.id)

      paper = [model.id,
        feeds_by_name[model.primary_category].id,
        "http://arxiv.org/abs/#{model.id}",
        "http://arxiv.org/pdf/#{model.id}.pdf",
        model.title,
        model.abstract,
        model.created,
        model.updated || model.created,
        model.authors
      ]
      paper_values.push(paper)
    end

    puts "Read #{models.length} items: #{paper_values.empty? ? "No" : paper_values.length} new papers to import."
    Paper.import(paper_columns, paper_values, validate: false)

    ### Finally: crosslists!

    crosslist_columns = [:paper_id, :feed_id, :cross_list_date]
    crosslist_values = []

    papers_by_ident = {}
    new_papers = Paper.find_all_by_identifier(paper_values.map { |p| p[0] })
    new_papers.each do |paper|
      papers_by_ident[paper.identifier] = paper
    end

    models.each do |model|
      paper = papers_by_ident[model.id]
      next if paper.nil?
      model.crosslists.each do |category|
        crosslist_values.push([
          papers_by_ident[model.id].id,
          feeds_by_name[category].id,
          model.created
        ])
      end
    end

    #puts "Importing #{crosslist_values.length} crosslists..." unless crosslist_values.empty?
    CrossList.import(crosslist_columns, crosslist_values, validate: false)
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
