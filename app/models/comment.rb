# == Schema Information
#
# Table name: comments
#
#  id                :integer          not null, primary key
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
#  deleted           :boolean          default(FALSE), not null
#  paper_uid         :text             default(""), not null
#

class Comment < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid, touch: true

  belongs_to :parent, class_name: "Comment" # Immediate reply ancestor
  belongs_to :ancestor, class_name: "Comment" # Highest-level reply ancestor

  validates :user, :paper, :content, presence: true

  has_many :reports, class_name: "CommentReport"
  has_many :children, foreign_key: 'parent_id', class_name: 'Comment'

  scope :visible, -> { where(hidden: false, deleted: false) }

  after_save do
    paper.refresh_comments_count!
  end

  after_destroy do
    paper.refresh_comments_count!
  end

  acts_as_votable

  def soft_delete
    self.update(deleted: true)
  end

  def restore
    self.update(deleted: false)
  end

  def self.find_all_by_feed_uids(feed_uids)
    Comment.joins(paper: :categories)
           .where(deleted: false, hidden: false, categories: { feed_uid: feed_uids })
           .group('comments.id')
           .order('comments.created_at DESC')
  end
end
