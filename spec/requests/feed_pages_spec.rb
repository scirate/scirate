require 'spec_helper'

describe "Feed pages" do
  subject { page }

  describe "feed page" do
    let(:feed) { FactoryGirl.create(:feed) }

    before do
      visit feed_path(feed)
    end

    it { should have_content feed.fullname }
  end
end
