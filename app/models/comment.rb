# == Schema Information
#
# Table name: comments
#
#  id                :integer          not null, primary key
#  paper_id          :integer          not null
#  user_id           :integer          not null
#  score             :integer          default(0), not null
#  cached_votes_up   :integer          default(0), not null
#  cached_votes_down :integer          default(0), not null
#  hidden            :boolean          default(FALSE), not null
#  parent_id         :integer
#  ancestor_id       :integer
#  created_at        :datetime
#  updated_at        :datetime
#  content           :text             not null
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
