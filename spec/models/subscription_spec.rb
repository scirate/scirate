require 'spec_helper'

describe Subscription do

  let(:user) { FactoryGirl.create(:user) }
  let(:feed) { FactoryGirl.create(:feed) }
  let(:subscription) do
    user.subscriptions.build(feed_id: feed.id)
  end

  subject { subscription }

  it { should be_valid }

  describe "when user id is not present" do
    before { subscription.user_id = nil }
    it { should_not be_valid }
  end

  describe "when feed id is not present" do
    before { subscription.feed_id = nil }
    it { should_not be_valid }
  end

  describe "user and feed methods" do
    before { subscription.save }

    it { should respond_to(:user) }
    it { should respond_to(:feed) }
    its(:user) { should == user }
    its(:feed) { should == feed }
  end

  describe "accessible attributes" do
    it "should not allow acces to user_id" do
      expect do
        Subscription.new(user_id: user.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
end
