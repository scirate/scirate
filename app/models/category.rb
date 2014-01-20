# == Schema Information
#
# Table name: categories
#
#  id             :integer          not null, primary key
#  position       :integer          not null
#  feed_uid       :text             not null
#  paper_uid      :text
#  crosslist_date :datetime         default(2014-01-16 20:06:20 UTC), not null
#

# Specifies that a paper belongs to a given category
class Category < ActiveRecord::Base
  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid
  belongs_to :feed, foreign_key: :feed_uid, primary_key: :uid

  validates :paper_uid, presence: true
  validates :feed_uid, presence: true
end
