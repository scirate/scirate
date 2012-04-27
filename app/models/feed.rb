# == Schema Information
#
# Table name: feeds
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  url          :string(255)
#  feed_type    :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  updated_date :date
#

class Feed < ActiveRecord::Base
  attr_accessible :name, :url, :feed_type, :updated_date

  has_many :papers, validate: false
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

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
