# == Schema Information
#
# Table name: feed_days
#
#  id         :integer         not null, primary key
#  pubdate    :date
#  content    :text
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  feed_name  :string(255)
#

class FeedDay < ActiveRecord::Base
  attr_accessible :pubdate, :content, :feed_name

  validates :pubdate, presence: true
  validates :content, presence: true
  validates :feed_name, presence: true

  validates_uniqueness_of :feed_name, :scope => [:pubdate]
end
