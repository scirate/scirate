# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  feed_uid   :text             default(""), not null
#

require 'spec_helper'

describe Subscription do
  let(:user) { FactoryGirl.create(:user) }
  let(:feed) { FactoryGirl.create(:feed) }
  let(:subscription) do
    user.subscriptions.build(feed_uid: feed.uid)
  end

  subject { subscription }

  it { should be_valid }
end
