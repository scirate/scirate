# == Schema Information
#
# Table name: cross_lists
#
#  id              :integer          not null, primary key
#  paper_id        :integer
#  feed_id         :integer
#  cross_list_date :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe CrossList do

  let(:paper) { FactoryGirl.create(:paper, feed: feed1) }
  let(:feed1) { FactoryGirl.create(:feed) }
  let(:feed2) { FactoryGirl.create(:feed) }

  let(:cross_list) do
    paper.cross_lists.build(feed_id: feed2.id, cross_list_date: Date.today)
  end

  subject{ cross_list }

  it { should be_valid }

  describe "when paper id is not present" do
    before { cross_list.paper_id = nil }
    it { should_not be_valid }
  end

  describe "when feed id is not present" do
    before { cross_list.feed_id = nil }
    it { should_not be_valid }
  end

  describe "when cross_list_date is not present" do
    before { cross_list.cross_list_date = nil }
    it { should_not be_valid }
  end

  describe "cross_list methods" do
    before { cross_list.save }

    it { should respond_to(:paper) }
    it { should respond_to(:feed) }

    its(:paper) { should == paper }
    its(:feed)  { should == feed2 }
  end
end
