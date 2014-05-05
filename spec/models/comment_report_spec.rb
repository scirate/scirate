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

require 'spec_helper'

describe CommentReport do
  it { should belong_to(:user) }
  it { should belong_to(:comment) }
  it { should validate_uniqueness_of(:comment_id).scoped_to(:user_id) }
end
