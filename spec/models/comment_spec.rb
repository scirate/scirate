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

require 'spec_helper'

describe Comment do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }

  before do
    @comment = user.comments.create(paper_uid: paper.uid, content: "Test comment.")
  end

  subject { @comment }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:paper_uid) }
  its(:user) { should == user }
  its(:paper){ should == paper }

  it { should be_valid }

  describe "when user id is not present" do
    before { @comment.user_id = nil }
    it { should_not be_valid }
  end

  describe "when paper id is not present" do
    before { @comment.paper_uid = nil }
    it { should_not be_valid }
  end

  describe "when content is not present" do
    before { @comment.content = " " }
    it { should_not be_valid }
  end

  describe '.find_all_by_feed_uids' do
    before do
      @feed_1 = FactoryGirl.create(:feed)
      @feed_2 = FactoryGirl.create(:feed)

      @paper_1 = FactoryGirl.create(:paper)
      @paper_2 = FactoryGirl.create(:paper)

      @category_1 = FactoryGirl.create(:category, feed: @feed_1, paper: @paper_1)
      @category_2 = FactoryGirl.create(:category, feed: @feed_2, paper: @paper_2)

      @comment_1 = FactoryGirl.create(:deleted_comment, paper: @paper_1)
      @comment_2 = FactoryGirl.create(:hidden_comment, paper: @paper_1)
      @comment_3 = FactoryGirl.create(:comment, paper: @paper_1, created_at: Date.today)
      @comment_4 = FactoryGirl.create(:comment, paper: @paper_1, created_at: Date.yesterday)
      @comment_5 = FactoryGirl.create(:comment, paper: @paper_2)
    end

    specify do
      results = described_class.find_all_by_feed_uids([@feed_1.uid])

      expect(results).to eq [@comment_3, @comment_4]
    end

  end
end
