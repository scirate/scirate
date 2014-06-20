# == Schema Information
#
# Table name: comments
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  score              :integer          default(0), not null
#  cached_votes_up    :integer          default(0), not null
#  cached_votes_down  :integer          default(0), not null
#  hidden             :boolean          default(FALSE), not null
#  parent_id          :integer
#  ancestor_id        :integer
#  created_at         :datetime
#  updated_at         :datetime
#  content            :text             not null
#  deleted            :boolean          default(FALSE), not null
#  paper_uid          :text             default(""), not null
#  hidden_from_recent :boolean          default(FALSE), not null
#

require 'spec_helper'

describe Comment do
  it { should belong_to(:user) }
  it { should belong_to(:paper) }
  it { should belong_to(:parent).class_name('Comment') }
  it { should belong_to(:ancestor).class_name('Comment') }
  it { should have_many(:reports).class_name('CommentReport') }
  it { should have_many(:children).class_name('Comment') }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:paper) }
  it { should validate_presence_of(:content) }

  describe "email alerts" do
    let(:user) { FactoryGirl.create(:user) }
    let(:parent_comment) { FactoryGirl.create(:comment, user: user) }

    it "sends an email on creating a comment" do
      FactoryGirl.create(:comment, parent: parent_comment)
      expect(last_email.to).to include(user.email)
    end
  end
end
