require 'spec_helper'

describe "Feed subscriptions" do

  subject { page }
  let(:feed) { Feed.default }
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end

  describe "subscribe" do
    before do
      post subscribe_path(feed.id)
    end

    it "should subscribe" do
      user.feeds.should include(feed)
    end
  end

  describe "unsubscribe" do
    before do
      post subscribe_path(feed.id)
      post unsubscribe_path(feed.id)
    end

    it "should unsubscribe" do
      user.feeds.should_not include(feed)
    end
  end
end
