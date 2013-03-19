# == Schema Information
#
# Table name: comments
#
#  id         :integer         primary key
#  content    :text
#  user_id    :integer
#  paper_id   :integer
#  created_at :timestamp       not null
#  updated_at :timestamp       not null

class Comment < ActiveRecord::Base
  attr_accessible :content, :paper_id

  belongs_to :user, counter_cache: true
  belongs_to :paper, counter_cache: true

  validates :user,    presence: true
  validates :paper,   presence: true
  validates :content, presence: true

  acts_as_votable
end
