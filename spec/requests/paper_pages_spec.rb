require 'spec_helper'

describe "Paper pages" do

  subject { page }

  describe "paper page" do
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      visit paper_path(paper)
    end

    it { should have_heading paper.title }
    it { should have_heading paper.identifier }
    it { should have_title paper.identifier }
    it { should have_content paper.authors[0] }
    it { should have_content paper.authors[1] }
    it { should have_content paper.abstract }
    it { should have_link paper.url }
    it { should have_content paper.pubdate.to_formatted_s(:rfc822) }
  end

  describe "index" do
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      visit papers_path
    end

    it { should have_title 'All papers' }

    describe "pagination" do
      before(:all) do
        30.times { FactoryGirl.create(:paper, pubdate: Date.today) }
        30.times { FactoryGirl.create(:paper, pubdate: Date.yesterday) }
      end
      after(:all)  { Paper.delete_all }

      it "should list all papers from today" do
        Paper.find_all_by_pubdate(Date.today).each do |paper|
          page.should have_link paper.identifier
          page.should have_content paper.title
        end
      end

      it "should not list all papers from yesterday" do
        Paper.find_all_by_pubdate(Date.yesterday).each do |paper|
          page.should_not have_link paper.identifier
          page.should_not have_content paper.title
        end
      end
    end
  end
end
