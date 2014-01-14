require 'spec_helper'

describe "Paper pages" do

  subject { page }

  describe "paper page" do
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      visit paper_path(paper)
    end

    it { should have_content paper.title }
    it { should have_content paper.identifier }
    it { should have_title paper.title }
    it { should have_content paper.authors[0] }
    it { should have_content paper.authors[1] }
    it { should have_content paper.abstract }
    it { should have_link paper.url }
    it { should have_content paper.pubdate.to_formatted_s(:rfc822) }
  end

  describe "index" do
    let(:feed) { Feed.default }
    let(:paper) { FactoryGirl.create(:paper, pubdate: Date.today, feed: feed) }
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    before do
      visit papers_path(date: Date.today)
    end
  end
end
