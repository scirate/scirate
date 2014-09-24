require 'spec_helper'

describe "Comment revision history", js: true do
  let!(:comment) { FactoryGirl.create(:comment, content: 'this is original comment') }
  let!(:user) { FactoryGirl.create(:user) }

  before do
    comment.edit!("this is edited comment", user.id)
    comment.soft_delete!(user.id)
    comment.restore!(user.id)

    sign_in user
  end

  describe "Revision history page" do
    before do
      visit comment_history_path(comment)
    end

    it "has all the event types" do
      expect(page).to have_content comment.user.fullname
      expect(page).to have_content "this is original comment"
      expect(page).to have_content user.fullname
      expect(page).to have_content "this is edited comment"
      expect(page).to have_content "Deleted by"
      expect(page).to have_content "Restored by"
    end
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
