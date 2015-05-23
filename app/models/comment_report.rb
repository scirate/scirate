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
  validates :comment_id, uniqueness: { scope: :user_id }

  after_create do
    subject = "*COMMENT REPORT* [SciRate] Re: #{self.comment.paper.title}"
    User.where(email_about_reported_comments: true).each do |user|
      UserMailer.comment_alert(user, self.comment, subject: subject).deliver_later
    end
  end
end
