# == Schema Information
#
# Table name: categories
#
#  id        :integer          not null, primary key
#  position  :integer          not null
#  feed_uid  :string(255)      not null
#  paper_uid :string(255)
#

# Specifies that a paper belongs to a given category
class Category < ActiveRecord::Base
  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid
  belongs_to :feed, foreign_key: :feed_uid, primary_key: :uid

  validates :paper_uid, presence: true
  validates :feed_uid, presence: true
end
