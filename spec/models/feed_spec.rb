# == Schema Information
#
# Table name: feeds
#
#  id                  :integer          not null, primary key
#  uid                 :text             not null
#  source              :text             not null
#  fullname            :text             not null
#  position            :integer          default(0), not null
#  subscriptions_count :integer          default(0), not null
#  last_paper_date     :datetime
#  parent_uid          :text
#

require 'spec_helper'

describe Feed do
  let(:feed) { FactoryGirl.create(:feed) }

  subject { feed }

  it { should respond_to(:uid) }
  it { should respond_to(:fullname) }
  it { should respond_to(:source) }
  it { should respond_to(:subscriptions) }
  it { should respond_to(:users) }
  it { should respond_to(:categories) }

  it { should be_valid }

  describe "subscribing" do
    let(:user) { FactoryGirl.create(:user) }
    before { user.subscribe!(feed) }

    it "can be subscribed to" do
      expect(feed.users.where(id: user.id)).to_not be_empty
    end

    it "can be unsubscribed from" do
      user.unsubscribe!(feed)
      expect(feed.users.where(id: user.id)).to be_empty
    end
  end

end
