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

    it "has the paper data" do
      expect(page).to have_content @paper.title
      expect(page).to have_content @paper.uid
      expect(page).to have_title @paper.title
      expect(page).to have_content @paper.authors[0].fullname
      expect(page).to have_content @paper.authors[1].fullname
      expect(page).to have_content @paper.abstract
      expect(page).to have_link @paper.abs_url
      expect(page).to have_content @paper.submit_date.to_date.to_formatted_s(:rfc822)

      expect(page).to have_content @paper.to_bibtex
    end
  end

  describe "scites page" do
    before(:all) do
      @user = FactoryGirl.create(:user)
      @user.scite!(@paper)

      visit paper_scites_path(@paper)
    end

    it "should show a scites page" do
      expect(page).to have_content @paper.title

      expect(page).to have_content @paper.scites_count
      expect(page).to have_content @user.fullname
    end
  end
end
