# == Schema Information
#
# Table name: feeds
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  url                 :string(255)
#  feed_type           :string(255)
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  updated_date        :date
#  subscriptions_count :integer         default(0)
#  last_paper_date     :date
#

require 'spec_helper'

describe Feed do

  before do
    @feed = Feed.new(name: "test-feed",
                     url: "http://scirate.com/feed",
                     feed_type: "arxiv",
                     updated_date: Date.today)
  end

  subject { @feed }

  it { should respond_to(:name) }
  it { should respond_to(:url) }
  it { should respond_to(:feed_type) }
  it { should respond_to(:is_default?) }
  it { should respond_to(:subscriptions) }
  it { should respond_to(:users) }
  it { should respond_to(:updated_date) }
  it { should respond_to(:cross_lists) }
  it { should respond_to(:cross_listed_papers) }

  it { should be_valid }

  it "should not be the default feed" do
    @feed.is_default?.should be_false
  end

  describe "when name is not present" do
    before { @feed.name = " " }
    it { should_not be_valid }
  end

  describe "when name is not unique" do
    before do
      feed_same_name = @feed.dup
      feed_same_name.url += 'delta'
      feed_same_name.save!
    end

    it { should_not be_valid }
  end

  describe "when feed_type is not present" do
    before { @feed.feed_type = " " }
    it { should_not be_valid }
  end

  describe "when updated_date is not present" do
    before { @feed.updated_date = nil }
    it { should_not be_valid }
  end

  describe "default feed" do
    before { @feed = Feed.default }

    it "should be quant-ph" do
      @feed.name.should == "quant-ph"
    end

    it "should be the default" do
      @feed.is_default?.should be_true
    end
  end

  describe "paper association" do
    before do
      @feed.save
      @paper = @feed.papers.create()
    end

    its "feed should be correct" do
      @paper.feed.should == @feed
    end

    it "should have the paper in the paper list" do
      @feed.papers.should include @paper
    end

    describe "default feed" do
      before { @feed = Feed.default }

      it "should not be quant-ph" do
        @feed.name.should == "quant-ph"
      end
    end
  end

  describe "user subscribing to a feed" do
    let (:user) { FactoryGirl.create(:user) }
    before do
      @feed.save
      user.save
      user.subscribe!(@feed)
    end

    its(:users) { should include(user) }

    describe "and unsubscribing" do
      before { user.unsubscribe!(@feed) }
      its(:users) { should_not include(user) }
    end
  end

end
