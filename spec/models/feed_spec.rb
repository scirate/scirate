# == Schema Information
#
# Table name: feeds
#
#  id                  :integer          not null, primary key
#  uid                 :string(255)      not null
#  source              :string(255)      not null
#  fullname            :string(255)      not null
#  parent_id           :integer
#  position            :integer          default(0), not null
#  subscriptions_count :integer          default(0), not null
#  last_paper_date     :datetime
#

require 'spec_helper'

describe Feed do

  before do
    @feed = Feed.new(uid: "test-feed",
                     fullname: "Test Feed",
                     source: "arxiv",
                     last_paper_date: Date.today)
  end

  subject { @feed }

  it { should respond_to(:uid) }
  it { should respond_to(:fullname) }
  it { should respond_to(:source) }
  it { should respond_to(:subscriptions) }
  it { should respond_to(:users) }
  it { should respond_to(:categories) }

  it { should be_valid }

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
