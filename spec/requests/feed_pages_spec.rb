require 'spec_helper'

describe "Feed pages" do
  subject { page }
  let!(:time) { Time.now+1.day }

  let!(:feed1) { FactoryGirl.create(:feed, last_paper_date: time) }
  let!(:feed2) { FactoryGirl.create(:feed, last_paper_date: time) }
  let!(:new_paper1) { FactoryGirl.create(:paper, feeds: [feed1], pubdate: time) }
  let!(:new_paper2) { FactoryGirl.create(:paper, feeds: [feed2], pubdate: time) }
  let!(:old_paper1) { FactoryGirl.create(:paper, feeds: [feed1], pubdate: time-1.day) }
  let!(:old_paper2) { FactoryGirl.create(:paper, feeds: [feed2], pubdate: time-1.day) }

  before do
    Search::Paper.index(new_paper1, new_paper2, old_paper1, old_paper2)
    Search.refresh
    Timecop.freeze(time)
  end

  after do
    Timecop.return
  end


  describe "Landing page" do
    before do
      visit root_path
    end

    it "shows today's papers" do
      expect(page).to have_content new_paper1.title
      expect(page).to have_content new_paper2.title
      expect(page).to_not have_content old_paper1.title
      expect(page).to_not have_content old_paper2.title
    end
  end
end
