# == Schema Information
#
# Table name: feeds
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  url                 :string(255)
#  feed_type           :string(255)
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  updated_date        :date
#  subscriptions_count :integer         default(0)
#  last_paper_date     :date
#

class Feed < ActiveRecord::Base
  attr_accessible :name, :url, :feed_type, :updated_date, :last_paper_date

  has_many :papers, validate: false
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :cross_lists, dependent: :destroy
  has_many :cross_listed_papers, through: :cross_lists, source: :paper

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
  validates :feed_type, presence: true
  validates :updated_date, presence: true

  def self.map_names
    mapping = {}
    Feed.all.each { |feed| mapping[feed.name] = feed }
    mapping
  end

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
                feed_type: "arxiv",
                updated_date: Date.today,
                last_paper_date: Date.today)
  end
end
