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

require 'spec_helper'

describe Comment do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }

  before do
    @comment = user.comments.create(paper_id: paper.id, content: "Test comment.")
  end

  subject { @comment }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:paper_id) }
  its(:user) { should == user }
  its(:paper){ should == paper }
  
  it { should be_valid }

  describe "when user id is not present" do
    before { @comment.user_id = nil }
    it { should_not be_valid }
  end

  describe "when paper id is not present" do
    before { @comment.paper_id = nil }
    it { should_not be_valid }
  end

  describe "when content is not present" do
    before { @comment.content = " " }
    it { should_not be_valid }
  end
end
