# == Schema Information
#
# Table name: comments
#
#  id         :integer         primary key
#  content    :text
#  user_id    :integer
#  paper_id   :integer
#  parent_id  :integer
#  created_at :timestamp       not null
#  updated_at :timestamp       not null
#  hidden     :boolean

class Comment < ActiveRecord::Base
  attr_accessible :parent_id, :paper_id, :content, :hidden

  belongs_to :user, counter_cache: true
  belongs_to :paper, counter_cache: true
  belongs_to :parent, class_name: "Comment"

  validates :user,    presence: true
  validates :paper,   presence: true
  validates :content, presence: true

  has_many :reports, class_name: "CommentReport"

  acts_as_votable
end
