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
