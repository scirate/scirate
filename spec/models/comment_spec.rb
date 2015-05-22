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
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:paper) }
  it { is_expected.to belong_to(:parent).class_name('Comment') }
  it { is_expected.to belong_to(:ancestor).class_name('Comment') }
  it { is_expected.to have_many(:reports).class_name('CommentReport') }
  it { is_expected.to have_many(:children).class_name('Comment') }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:paper) }
  it { is_expected.to validate_presence_of(:content) }

  describe "counters" do
    let(:user) { FactoryGirl.create(:user) }
    let(:comment) { FactoryGirl.create(:comment, user: user) }

    it "updates comment count on save" do
      comment.save!
      expect(user.comments_count).to eq(1)
    end

    it "updates comment count on soft delete" do
      comment.soft_delete!(user.id)
      expect(user.comments_count).to eq(0)
    end
  end

  describe "email alerts" do
    describe "email_about_replies" do
      let(:user) { FactoryGirl.create(:user) }
      let(:comment) { FactoryGirl.create(:comment, user: user) }

      it "sends reply alerts by default" do
        FactoryGirl.create(:comment, parent: comment)
        expect(last_email.to).to include(user.email)
      end

      it "doesn't send them when disabled" do
        user.email_about_replies = false
        user.save!
        FactoryGirl.create(:comment, parent: comment)
        expect(last_email).to be_nil
      end
    end

    describe "email_about_comments_on_authored" do
      let(:paper) { FactoryGirl.create(:paper) }
      let(:user) { FactoryGirl.create(:user) }

      before do
        Authorship.create(user: user, paper: paper)
      end

      it "sends alerts to claimants of papers by default" do
        FactoryGirl.create(:comment, paper: paper)
        expect(last_email.to).to include(user.email)
      end

      it "doesn't send them when disabled" do
        user.email_about_comments_on_authored = false
        user.save!
        FactoryGirl.create(:comment, paper: paper)
        expect(last_email).to be_nil
      end
    end

    describe "email_about_comments_on_scited" do
      let(:paper) { FactoryGirl.create(:paper) }
      let(:user) { FactoryGirl.create(:user) }

      before do
        user.scite!(paper)
      end

      it "doesn't send alerts to sciters by default" do
        FactoryGirl.create(:comment, paper: paper)
        expect(last_email).to be_nil
      end

      it "sends them when enabled" do
        user.email_about_comments_on_scited = true
        user.save!
        FactoryGirl.create(:comment, paper: paper)
        expect(last_email.to).to include(user.email)
      end
    end
  end
end
