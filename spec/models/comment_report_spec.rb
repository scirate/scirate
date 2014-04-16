require 'spec_helper'

describe CommentReport do
  it { should belong_to(:user) }
  it { should belong_to(:comment) }
  it { should validate_uniqueness_of(:comment_id).scoped_to(:user_id) }
end
