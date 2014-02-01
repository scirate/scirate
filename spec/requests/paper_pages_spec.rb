require 'spec_helper'

describe "Paper pages" do

  subject { page }

  describe "paper page" do
    let(:paper) { 
      paper = FactoryGirl.create(:paper)
      category = FactoryGirl.build(:category)
      paper.categories = [category]
      paper.save
      paper
    }

    before do
      visit paper_path(paper)
    end

    it { should have_content paper.title }
    it { should have_content paper.uid }
    it { should have_title paper.title }
    it { should have_content paper.authors[0].fullname }
    it { should have_content paper.authors[1].fullname }
    it { should have_content paper.abstract }
    it { should have_link paper.abs_url }
    it { should have_content paper.submit_date.to_date.to_formatted_s(:rfc822) }
  end

  describe "scites page" do
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      visit paper_scites_path(paper)
    end

    it { should have_content paper.title }
  end
end
