require 'spec_helper'

describe ApiController do

  let(:user)  { FactoryGirl.create(:user) }
  let(:feed) { Feed.default }
  let(:paper) { FactoryGirl.create(:paper) }

  before { sign_in user }

  describe "sciting a paper" do
    it "should increment the Scite count" do
      expect do
        xhr :post, :scite, paper_id: paper.id
      end.to change(Scite, :count).by(1)
    end

    it "should respond with success" do
      xhr :post, :scite, paper_id: paper.id
      response.should be_success
    end
  end

  describe "unsciting a paper" do
    before do
      user.scite!(paper)
    end

    it "should decrement the Scite count" do
      expect do
        xhr :post, :unscite, paper_id: paper.id
      end.to change(Scite, :count).by(-1)
    end

    it "should respond with success" do
      xhr :post, :unscite, paper_id: paper.id
      response.should be_success
    end
  end

  describe "subscribing to a feed" do
    before do
      xhr :post, :subscribe, feed_id: feed.id
    end

    it "should subscribe" do
      user.feeds.should include(feed)
    end
  end

  describe "unsubscribing from a feed" do
    before do
      xhr :post, :subscribe, feed_id: feed.id
      xhr :post, :unsubscribe, feed_id: feed.id
    end

    it "should unsubscribe" do
      user.feeds.should_not include(feed)
    end
  end
end
