class Comment < ActiveRecord::Base
  attr_accessible :content, :paper_id

  belongs_to :user, counter_cache: true
  belongs_to :paper, counter_cache: true

  validates :user,    presence: true
  validates :paper,   presence: true
  validates :content, presence: true
end
