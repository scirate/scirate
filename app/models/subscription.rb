class Subscription < ActiveRecord::Base
  attr_accessible :feed_id

  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true
end
