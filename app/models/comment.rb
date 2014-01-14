# == Schema Information
#
# Table name: comments
#
#  id                :integer          not null, primary key
#  content           :text
#  user_id           :integer
#  paper_id          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  score             :integer
#  cached_votes_up   :integer          default(0)
#  cached_votes_down :integer          default(0)
#  parent_id         :integer
#  hidden            :boolean          default(FALSE)
#  reply_id          :integer
#  ancestor_id       :integer
#

class Comment < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :paper, counter_cache: true

  belongs_to :parent, class_name: "Comment" # Immediate reply ancestor
  belongs_to :ancestor, class_name: "Comment" # Highest-level reply ancestor

  validates :user,    presence: true
  validates :paper,   presence: true
  validates :content, presence: true

  has_many :reports, class_name: "CommentReport"
  has_many :children, foreign_key: 'parent_id', class_name: 'Comment'

  acts_as_votable
end
