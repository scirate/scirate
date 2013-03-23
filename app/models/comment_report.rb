class CommentReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment

  # User can't report a comment multiple times
  validates_uniqueness_of :comment_id, :scope => :user_id
end
