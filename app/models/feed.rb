# == Schema Information
#
# Table name: feeds
#
#  id                  :integer         primary key
#  name                :string(255)
#  url                 :string(255)
#  feed_type           :string(255)
#  created_at          :timestamp       not null
#  updated_at          :timestamp       not null
#  updated_date        :date
#  subscriptions_count :integer         default(0)
#

class Feed < ActiveRecord::Base
  attr_accessible :name, :url, :feed_type, :updated_date

  has_many :papers, validate: false
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :cross_lists, dependent: :destroy
  has_many :cross_listed_papers, through: :cross_lists, source: :paper

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
  validates :feed_type, presence: true

  def to_param
    name
  end

  def self.default
    default = Feed.find_by_name("quant-ph") || Feed.create_default
  end

  def is_default?
    self == Feed.default
  end

  def self.create_default
    Feed.create(name: "quant-ph",
                url: "http://export.arxiv.org/rss/quant-ph",
                feed_type: "arxiv")
  end
end
