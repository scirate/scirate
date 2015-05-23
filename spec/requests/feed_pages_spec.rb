require 'spec_helper'

describe "Feed pages" do
  subject { page }
  let!(:time) { Chronic.parse("2015-01-05") }

  let!(:feed1) { FactoryGirl.create(:feed, last_paper_date: time) }
  let!(:feed2) { FactoryGirl.create(:feed, last_paper_date: time) }
  let!(:new_paper1) { FactoryGirl.create(:paper, uid: "1001.1001", title: "New Paper 1", feeds: [feed1], pubdate: time) }
  let!(:new_paper2) { FactoryGirl.create(:paper, uid: "1001.1002", title: "New Paper 2", feeds: [feed2], pubdate: time) }
  let!(:old_paper1) { FactoryGirl.create(:paper, title: "Old Paper 1", feeds: [feed1], pubdate: time-1.day) }
  let!(:old_paper2) { FactoryGirl.create(:paper, title: "Old Paper 2", feeds: [feed2], pubdate: time-1.day) }

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
      p page.find('li.paper:nth-child(1) .title').text
      p page.find('li.paper:nth-child(2) .title').text
      expect(page).to have_selector("li.paper:nth-child(1) .title", text: new_paper1.title)
      expect(page).to have_selector("li.paper:nth-child(2) .title", text: new_paper2.title)
      expect(page).to_not have_content old_paper1.title
      expect(page).to_not have_content old_paper2.title
    end
  end

  describe "Home feed" do
    let(:user) { FactoryGirl.create(:user) }
    let(:prefs) { user.feed_preferences.where(feed_uid: nil).first_or_create }

    before do
      user.subscribe!(feed1)
      sign_in user
    end

    context "after not visiting for two days" do
      before do
        prefs.previous_last_visited = time-5.days
        prefs.last_visited = time-2.days
        prefs.save!
        visit root_path
      end

      it "shows the last two days of papers" do
        expect(page).to have_selector("li.paper:nth-child(1)", text: new_paper1.title)
        expect(page).to have_selector("li.paper:nth-child(2)", text: old_paper1.title)
        expect(page).to_not have_content new_paper2.title
        expect(page).to_not have_content old_paper2.title

        prefs.reload
        expect(prefs.previous_last_visited).to eq(time-2.days)
        expect(prefs.last_visited).to eq(feed1.last_paper_date)
      end
    end

    context "visiting again in the same day" do
      before do
        prefs.previous_last_visited = time-2.days
        prefs.last_visited = feed1.last_paper_date
        prefs.save!
        visit root_path
      end

      it "still shows the last two days of papers" do
        expect(page).to have_selector("li.paper:nth-child(1)", text: new_paper1.title)
        expect(page).to have_selector("li.paper:nth-child(2)", text: old_paper1.title)
        expect(page).to_not have_content new_paper2.title
        expect(page).to_not have_content old_paper2.title

        prefs.reload
        expect(prefs.previous_last_visited).to eq(time-2.days)
        expect(prefs.last_visited).to eq(feed1.last_paper_date)
      end
    end

    context "visiting two days in a row" do
      before do
        prefs.previous_last_visited = Chronic.parse("2015-01-03 23:59 UTC")
        prefs.last_visited = Chronic.parse("2015-01-04 23:59 UTC")
        prefs.save!
        visit root_path
      end

      it "shows only a single day of papers" do
        expect(page).to have_selector("li.paper:nth-child(1)", text: new_paper1.title)
        expect(page).to_not have_selector("li.paper:nth-child(2)", text: old_paper1.title)
        expect(page).to_not have_content new_paper2.title
        expect(page).to_not have_content old_paper2.title

        prefs.reload
        expect(prefs.previous_last_visited).to eq Chronic.parse("2015-01-04 23:59 UTC")
        expect(prefs.last_visited).to eq(feed1.last_paper_date)
      end
    end


    context "changing order by sciting a paper" do
      before do
        prefs.previous_last_visited = time-2.days
        prefs.last_visited = time
        prefs.save!
        user.scite!(old_paper1)
        Search.refresh
        visit root_path
      end

      it "shows the older paper first" do
        expect(page).to have_selector("li.paper:nth-child(1)", text: old_paper1.title)
        expect(page).to have_selector("li.paper:nth-child(2)", text: new_paper1.title)
      end
    end
  end
end
