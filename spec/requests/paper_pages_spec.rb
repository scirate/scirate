require 'spec_helper'

describe "Paper pages" do
  before(:all) do
    @paper = FactoryGirl.create(:paper_with_authors)
    FactoryGirl.create(:category, paper: @paper)
    FactoryGirl.create(:comment, paper: @paper)
    @paper.reload
  end

  describe "paper page" do
    before(:all) do
      visit paper_path(@paper)
    end

    it "should have the paper data" do
      page.should have_content @paper.title
      page.should have_content @paper.uid
      page.should have_title @paper.title
      page.should have_content @paper.authors[0].fullname
      page.should have_content @paper.authors[1].fullname
      page.should have_content @paper.abstract
      page.should have_link @paper.abs_url
      page.should have_content @paper.submit_date.to_date.to_formatted_s(:rfc822)
    end
  end

  describe "scites page" do
    before(:all) do
      @user = FactoryGirl.create(:user)
      @user.scite!(@paper)

      visit paper_scites_path(@paper)
    end

    it "should show a scites page" do
      page.should have_content @paper.title

      page.should have_content @paper.scites_count
      page.should have_content @user.fullname
    end
  end
end
