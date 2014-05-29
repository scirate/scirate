class UserAuthor < ActiveRecord::Base
  belongs_to :user
  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid

  validates :user, presence: true
  validates :paper, presence: true
end
