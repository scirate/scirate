class Feed < ActiveRecord::Base
  attr_accessible :name, :url, :feed_type

  has_many :papers

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
  validates :feed_type, presence: true
end
