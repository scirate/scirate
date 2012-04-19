class Feed < ActiveRecord::Base
  attr_accessible :name, :url, :feed_type

  has_many :papers
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
  validates :feed_type, presence: true

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
