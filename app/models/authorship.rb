class Authorship < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid, touch: true

  validates :user, presence: true
  validates :paper, presence: true

  before_create do
    self.created_at = paper.pubdate
  end
end
