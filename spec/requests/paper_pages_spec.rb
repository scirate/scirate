require 'spec_helper'

describe "Paper pages" do
  before(:all) do
    @paper = FactoryGirl.create(:paper,
      uid: "1404.5997",
      title: "One weird trick for parallelizing convolutional neural networks",
      pdf_url: "http://arxiv.org/pdf/1404.5997.pdf",
      pubdate: Chronic.parse("25 Apr 2014")
    )
    FactoryGirl.create(:author, paper: @paper,
      fullname: "Alex Krizhevsky",
      searchterm: "Krizhevsky_A"
    )
    FactoryGirl.create(:author, paper: @paper)
    FactoryGirl.create(:category, paper: @paper)
    FactoryGirl.create(:comment, paper: @paper)
    @paper.reload
  end

  describe "paper page" do
    before do
      visit paper_path(@paper)
    end

    it "has Google Scholar metadata" do
      expect(find('meta[name="citation_title"]', visible: false)['content'])
        .to eq "One weird trick for parallelizing convolutional neural networks"
      expect(find('meta[name="citation_author"]', match: :first, visible: false)['content'])
        .to eq "Krizhevsky, Alex"
      expect(find('meta[name="citation_publication_date"]', visible: false)['content'])
        .to eq "2014/04/25"
      expect(find('meta[name="citation_pdf_url"]', visible: false)['content'])
        .to eq "http://arxiv.org/pdf/1404.5997.pdf"
      expect(find('meta[name="citation_arxiv_id"]', visible: false)['content'])
        .to eq "1404.5997"
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

describe "Commenting on a paper", js: true do
  let(:paper) { FactoryGirl.create(:paper, :with_categories) }
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
    visit paper_path(paper)
    fill_in "wmd-input", with: "A spiffy comment"
    click_button "Leave Comment"
  end

  it "posts the comment" do
    expect(page).to have_success_message
    expect(page).to have_comment "A spiffy comment"
  end
end

=begin
describe "Paper page javascript", js: true do
  let(:paper) { FactoryGirl.create(:paper, :with_categories) }

  before do
    visit paper_path(paper)
  end

  it "selects the bibtex" do
    click_button "Copy Citation"

    test = page.driver.evaluate_script %Q{
      window.getSelection().baseNode.getAttribute('class')
    }
    expect(test).to eq "reference"
  end
end
=end
