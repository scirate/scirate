# == Schema Information
#
# Table name: comment_reports
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  comment_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CommentReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment

  # User can't report a comment multiple times
  validates_uniqueness_of :comment_id, :scope => :user_id
end
