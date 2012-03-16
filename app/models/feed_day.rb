# == Schema Information
#
# Table name: feed_days
#
#  id         :integer         not null, primary key
#  pubdate    :date
#  content    :text
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class FeedDay < ActiveRecord::Base
  attr_accessible :pubdate, :content

  validates :pubdate, presence: true, uniqueness: true
  validates :content, presence: true
end
