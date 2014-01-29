require 'spec_helper'

describe ApiController do

  let(:user)  { FactoryGirl.create(:user) }
  let(:feed) { FactoryGirl.create(:feed) }
  let(:paper) { FactoryGirl.create(:paper) }

  before { sign_in user }

  describe "sciting a paper" do
    it "should increment the Scite count" do
      expect do
        xhr :post, :scite, paper_uid: paper.uid
      end.to change(Scite, :count).by(1)
    end

    it "should respond with success" do
      xhr :post, :scite, paper_uid: paper.uid
      response.should be_success
    end
  end

  describe "unsciting a paper" do
    before do
      user.scite!(paper)
    end

    it "should decrement the Scite count" do
      expect do
        xhr :post, :unscite, paper_uid: paper.uid
      end.to change(Scite, :count).by(-1)
    end

    it "should respond with success" do
      xhr :post, :unscite, paper_uid: paper.uid
      response.should be_success
    end
  end

  describe "subscribing to a feed" do
    before do
      xhr :post, :subscribe, feed_uid: feed.uid
    end

    it "should subscribe" do
      user.feeds.should include(feed)
    end
  end

  describe "unsubscribing from a feed" do
    before do
      xhr :post, :subscribe, feed_uid: feed.uid
      xhr :post, :unsubscribe, feed_uid: feed.uid
    end

    it "should unsubscribe" do
      user.feeds.should_not include(feed)
    end
  end
end
