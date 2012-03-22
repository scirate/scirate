class Comment < ActiveRecord::Base
  attr_accessible :content, :paper_id

  belongs_to :user
  belongs_to :paper

  validates :user,    presence: true
  validates :paper,   presence: true
  validates :content, presence: true
end
