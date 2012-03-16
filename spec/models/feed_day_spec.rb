# == Schema Information
#
# Table name: feed_days
#
#  id         :integer         not null, primary key
#  pubdate    :date
#  content    :text
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe FeedDay do

  before do
    @feed_day = FeedDay.new(pubdate: Date.today, content: "Some content")
  end

  subject { @feed_day }

  it { should respond_to(:pubdate) }
  it { should respond_to(:content) }

  it { should be_valid }

  describe "when date is not present" do
    before { @feed_day.pubdate = " " }
    it { should_not be_valid }
  end

  describe "when content is not present" do
    before { @feed_day.content = " "}
    it { should_not be_valid }
  end

  describe "when date is duplicated" do
    before do
      feed_day_with_same_pubdate = @feed_day.dup
      feed_day_with_same_pubdate.save
    end

    it { should_not be_valid }
  end
end
