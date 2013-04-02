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

  def self.import_metadata(metadatas)
    identifiers = metadatas.map(&:id)

    # Some of these may already be in the database: update them
    existing = {}
    Paper.find_all_by_identifier(identifiers).each do |paper|
      existing[paper.identifier] = paper
    end

    metadatas.each do |metadata|
      paper = existing[metadata.id]
      if paper.nil?
        paper = Paper.new(identifier: metadata.id)
        new_paper = true
      end

      paper.feed_id = Feed.get_or_create(metadata.primary_category).id
      paper.title = metadata.title
      paper.abstract = metadata.abstract
      paper.url = "http://arxiv.org/abs/#{paper.identifier}"
      paper.pdf_url = "http://arxiv.org/pdf/#{paper.identifier}.pdf"
      paper.pubdate = metadata.created
      paper.updated_date = metadata.updated || paper.pubdate
      paper.authors = metadata.authors.map(&:name)
      paper.save!

      # fetch crosslists -- the first returned element is the primary category
      categories = metadata.categories.drop(1)

      # create crosslists
      categories.each do |c|
        feed = Feed.get_or_create(c)

        # don't recreate cross-list if it already exists
        if new_paper || !paper.cross_listed_feeds.include?(feed)
          paper.cross_lists.create!(feed_id: feed.id, \
                                    cross_list_date: paper.pubdate)
        end
      end      
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
