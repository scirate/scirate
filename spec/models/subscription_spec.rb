# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer         primary key
#  user_id    :integer
#  feed_id    :integer
#  created_at :timestamp       not null
#  updated_at :timestamp       not null
#

require 'spec_helper'

describe Subscription do
  let(:user) { FactoryGirl.create(:user) }
  let(:feed) { FactoryGirl.create(:feed) }
  let(:subscription) do
    user.subscriptions.build(feed_id: feed.id)
  end

  subject { subscription }

  it { should be_valid }
end
