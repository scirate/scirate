require 'spec_helper'

describe ApiController do
  let(:user)  { FactoryGirl.create(:user) }
  let(:feed) { FactoryGirl.create(:feed) }
  let(:paper) { FactoryGirl.create(:paper) }

  before { become user }

  describe "sciting a paper" do
    before do
      post :scite, params: { paper_uid: paper.uid }, xhr: true
    end

    it "creates a scite" do
      scite = Scite.where(user_id: user.id, paper_uid: paper.uid).first
      expect(scite).to_not be_nil
      expect(response).to be_successful
    end
  end

  describe "unsciting a paper" do
    before do
      post :scite, params: { paper_uid: paper.uid }, xhr: true
      post :unscite, params: { paper_uid: paper.uid }, xhr: true
    end

    it "removes the scite" do
      scite = Scite.where(user_id: user.id, paper_uid: paper.uid).first
      expect(scite).to be_nil

      expect(response).to be_successful
    end
  end

  describe "subscribing to a feed" do
    before do
      post :subscribe, params: { feed_uid: feed.uid }, xhr: true
    end

    it "creates a subscription" do
      sub = Subscription.where(user_id: user.id, feed_uid: feed.uid).first
      expect(sub).to_not be_nil

      expect(response).to be_successful
    end
  end

  describe "unsubscribing from a feed" do
    before do
      post :subscribe, params: { feed_uid: feed.uid }, xhr: true
      post :unsubscribe, params: { feed_uid: feed.uid }, xhr: true
    end

    it "removes the subscription" do
      sub = Subscription.where(user_id: user.id, feed_uid: feed.uid).first
      expect(sub).to be_nil

      expect(response).to be_successful
    end
  end

  describe "moderator: hiding a comment from recent comments" do
    let(:comment) { FactoryGirl.create(:comment) }
    let(:moderator) { FactoryGirl.create(:user, :moderator) }

    context "as a normal user" do
      before do
        post :hide_from_recent, params: { comment_id: comment.id }, xhr: true
      end

      it "throws a 403" do
        expect(response).to_not be_successful
        expect(comment.reload.hidden_from_recent).to be_falsey
      end
    end

    context "as a moderator" do
      before do
        become moderator
        post :hide_from_recent, params: { comment_id: comment.id }, xhr: true
      end

      it "hides the comment" do
        expect(response).to be_successful
        expect(comment.reload.hidden_from_recent).to be_truthy
      end
    end
  end
end
