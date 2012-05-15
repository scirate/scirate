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
    it { should have_title paper.identifier }
    it { should have_content paper.authors[0] }
    it { should have_content paper.authors[1] }
    it { should have_content paper.abstract }
    it { should have_link paper.url }
    it { should have_content paper.pubdate.to_formatted_s(:rfc822) }

    describe "when a paper has not been updated" do
      before do
        paper.updated_date = paper.pubdate
        paper.save

        visit paper_path(paper)
      end

      it { should_not have_content "Updated on" }
    end

    describe "when a paper has been updated" do
      before do
        paper.updated_date = paper.pubdate + 1
        paper.save

        visit paper_path(paper)
      end

      it { should have_content paper.updated_date.to_formatted_s(:rfc822) }
    end

    describe "cross-listed papers" do
      let(:other_feed) { FactoryGirl.create(:feed) }

      describe "when there are no cross-listings" do

        before do
          visit paper_path(paper)
        end

        it "should not display cross-listings" do
          page.should_not have_content "Subjects:"
        end
      end

      describe "when there are cross-listings" do

        before do
          paper.cross_lists.create!(feed_id: other_feed.id, \
                                    cross_list_date: Date.today)
          visit paper_path(paper)
        end

        it "should display cross-listings" do
          page.should have_content "Subjects:"
        end

        it "should list the cross-listed feeds" do
          paper.cross_listed_feeds.each do |f|
            page.should have_content f.name
          end
        end
      end
    end

    describe "sciting/unsciting" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "sciting a paper" do
        before { visit paper_path(paper) }

        it "should increment the scited papers count" do
          expect do
            click_button "Scite!"
          end.to change(user.scited_papers, :count).by(1)
        end

        it "should increment the paper's scites count" do
          expect do
            click_button "Scite!"
          end.to change(paper.sciters, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Scite!" }
          it { should have_selector('input', value: "Unscite") }
        end
      end

      describe "unsciting a paper" do
        before do
          user.scite!(paper)
          visit paper_path(paper)
        end

        it "should decement the scited papers count" do
          expect do
            click_button "Unscite"
          end.to change(user.scited_papers, :count).by(-1)
        end

        it "should decrement the paper's scites count" do
          expect do
            click_button "Unscite"
          end.to change(paper.sciters, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unscite" }
          it { should have_selector('input', value: "Scite!") }
        end
      end

      describe "should list sciters" do
        let(:user) { FactoryGirl.create(:user) }
        let(:other_user) { FactoryGirl.create(:user) }

        before do
          user.scite!(paper)
          visit paper_path(paper)
        end

        it { should have_content user.name }
        it { should_not have_content other_user.name }
      end
    end

    describe "comments" do
      let(:user) { FactoryGirl.create(:user) }
      let(:other_user) { FactoryGirl.create(:user) }
      let(:other_paper) { FactoryGirl.create(:paper) }

      describe "should list all comments for paper" do
        before do
          5.times { |n| user.comments.create(paper_id: paper.id,  content: "This is comment number #{n+1}.") }
          5.times { |n| other_user.comments.create(paper_id: paper.id,  content: "This is comment number #{n+6}.") }

          5.times { |n| user.comments.create(paper_id: other_paper.id,  content: "This is other comment number #{n+1}.") }
          5.times { |n| other_user.comments.create(paper_id: other_paper.id,  content: "This is other comment number #{n+6}.") }

          visit paper_path(paper)
        end

        it "should have all comments" do
          paper.comments.each do |comment|
            page.should have_content comment.content
          end
        end

        it "should not have comments from other papers" do
          other_paper.comments.each do |comment|
            page.should_not have_content comment.content
          end
        end

        it "should link to name of commenters" do
          paper.comments.each do |comment|
            page.should have_link comment.user.name
          end
        end

        it "should list comment time/date" do
          paper.comments.each do |comment|
            page.should have_content comment.created_at.to_formatted_s(:short)
          end
        end

        it "should list the nubmer of comments" do
          page.should have_content "10 comments"
        end
      end

      describe "leaving a comment" do

        describe "when not signed in" do
          before { visit paper_path(paper) }

          it { should_not have_button "Leave Comment" }
          it { should_not have_field "comment[content]" }
        end

        describe "when signed in" do
          before do
            sign_in user
            visit paper_path(paper)
          end

          it { should have_button "Leave Comment" }
          it { should have_field "comment[content]" }

          describe "with no content" do
            it "should not increment user's comments count" do
              expect do
                click_button "Leave Comment"
              end.not_to change(user.comments, :count)
            end

            it "should not increment paper's comments count" do
              expect do
                click_button "Leave Comment"
              end.not_to change(paper.comments, :count)
            end

            it "should not create a comment" do
              expect do
                click_button "Leave Comment"
              end.not_to change(Comment, :count)
            end

            it "should generate an error message" do
              click_button "Leave Comment"
              page.should have_content "Error posting comment"
            end
          end

          describe "with valid content" do
            before { fill_in "comment[content]", with: "Test comment." }

            it "should increment user's comments count" do
              expect do
                click_button "Leave Comment"
              end.to change(user.comments, :count).by(1)
            end

            it "should increment paper's comments count" do
              expect do
                click_button "Leave Comment"
              end.to change(paper.comments, :count).by(1)
            end

            it "should create a comment" do
              expect do
                click_button "Leave Comment"
              end.to change(Comment, :count).by(1)
            end

            it "should generate an success message" do
              click_button "Leave Comment"
              page.should have_content "Comment posted"
            end
          end
        end
      end
    end
  end

  describe "index" do
    let(:feed) { Feed.default }
    let(:paper) { FactoryGirl.create(:paper, pubdate: Date.today, feed: feed) }
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    before do
      visit papers_path(date: Date.today)
    end

    it { should have_title "Papers for #{Feed.default.name} from #{Date.today.to_formatted_s(:short)}" }

    describe "scites display" do
      describe "when the paper has no scites" do
        before do
          paper.save
          visit papers_path(date: Date.today)
        end

        it { should have_content "0 Scites" }
      end

      describe "when the paper has one scite" do
        before do
          user.scite!(paper)
          visit papers_path(date: Date.today)
        end

        it { should have_content "1 Scite" }
        it { should_not have_content "1 Scites" }
      end

      describe "when the paper has two scites" do
        before do
          user.scite!(paper)
          other_user.scite!(paper)

          visit papers_path(date: Date.today)
        end

        it { should have_content "2 Scites" }
      end
    end

    describe "comments display" do
      describe "when the paper has no comments" do
        before do
          paper.save
          visit papers_path(date: Date.today)
        end

        it { should_not have_link "Comment" }
      end

      describe "when the paper has one comment" do
        before do
          user.comments.create(paper_id: paper.id, content: "Hi.")
          visit papers_path(date: Date.today)
        end

        it { should have_link "1 Comment" }
        it { should_not have_link "1 Comments" }
      end

      describe "when the paper has two comments" do
        before do
          user.comments.create(paper_id: paper.id, content: "Hi.")
          other_user.comments.create(paper_id: paper.id, content: "Ho.")
          visit papers_path(date: Date.today)
        end

        it { should have_link "2 Comments" }
      end
    end

    describe "cross-listed papers" do
      let(:other_feed) { FactoryGirl.create(:feed) }
      let(:other_paper) { FactoryGirl.create(:paper, pubdate: Date.today, feed: other_feed) }
      let(:yet_another_paper) { FactoryGirl.create(:paper, pubdate: Date.today, feed: other_feed) }

      before do
        other_paper.cross_lists.create!(feed_id: feed.id, cross_list_date: Date.today)
        visit papers_path(date: Date.today)
      end

      it "should list the cross-listed paper" do
        page.should have_link other_paper.identifier
        page.should have_content other_paper.title
      end

      it "should not list non cross-listed papers" do
        page.should_not have_link yet_another_paper.identifier
        page.should_not have_content yet_another_paper.title
      end

      describe "with subscriptions" do
        before do
          user.subscribe!(feed)
          sign_in user
          visit papers_path(date: Date.today)
        end

        it "should list the cross-listed paper" do
          page.should have_link other_paper.identifier
          page.should have_content other_paper.title
        end

        it "should not list non cross-listed papers" do
          page.should_not have_link yet_another_paper.identifier
          page.should_not have_content yet_another_paper.title
        end
      end
    end

    describe "pagination" do
      before(:all) do
        3.times { FactoryGirl.create(:paper, pubdate: Date.today, feed: Feed.default) }
        3.times { FactoryGirl.create(:paper, pubdate: Date.yesterday, feed: Feed.default) }
        3.times { FactoryGirl.create(:paper, pubdate: Date.yesterday - 1, feed: Feed.default) }
      end
      after(:all) do
        Paper.delete_all
      end

      it "should list all papers from today" do
        Feed.default.papers.find_all_by_pubdate(Date.today).each do |paper|
          page.should have_link paper.identifier
          page.should have_content paper.title
        end
      end

      it "should not list all papers from yesterday" do
        Feed.default.papers.find_all_by_pubdate(Date.yesterday).each do |paper|
          page.should_not have_link paper.identifier
          page.should_not have_content paper.title
        end
      end

      it "should have links to the next and previous days" do
        page.should have_link "Next"
        page.should have_link "Prev"
      end

      describe "next day" do
        describe "on last day" do
          before { visit papers_next_path(date: Date.today) }

          it { should have_content "No future papers found!" }
          it { should have_title "Papers for #{Feed.default.name} from #{Date.today.to_formatted_s(:short)}" }
        end

        describe "on arbitrary day" do
          before { visit papers_next_path(date: Date.today - 1.day) }

          it { should_not have_content "No future papers found!" }
          it { should have_title "Papers for #{Feed.default.name} from #{Date.today.to_formatted_s(:short)}" }
        end
      end

      describe "prev day" do
        describe "on first day" do
          before { visit papers_prev_path(date: Date.today - 2.days) }

          it { should have_content "No past papers found!" }
          it { should have_title "Papers for #{Feed.default.name} from #{(Date.today - 2.days).to_formatted_s(:short)}" }
        end

        describe "on arbitrary day" do
          before { visit papers_prev_path(date: Date.today) }

          it { should_not have_content "No past papers found!" }
          it { should have_title "Papers for #{Feed.default.name} from #{(Date.today-1.day).to_formatted_s(:short)}" }
        end
      end
    end

    describe "feeds" do
      let(:feed) { FactoryGirl.create(:feed) }

      before do
        2.times { FactoryGirl.create(:paper, feed: feed, pubdate: Date.today) }
        2.times { FactoryGirl.create(:paper, feed: feed, pubdate: Date.yesterday) }
        2.times { FactoryGirl.create(:paper, feed: feed, pubdate: Date.yesterday - 1.day) }
        2.times { FactoryGirl.create(:paper, feed: Feed.default, pubdate: Date.yesterday) }

        visit papers_path(feed: feed.name, date: Date.yesterday)
      end

      it "should list all of right day's papers from first feed" do
        feed.papers.find_all_by_pubdate(Date.yesterday).each do |paper|
          page.should have_link paper.identifier
          page.should have_content paper.title
        end
      end

      it "should not list any papers from default feed" do
        Feed.default.papers.each do |paper|
          page.should_not have_link paper.identifier
          page.should_not have_content paper.title
        end
      end

      describe "next button and feeds" do
        before { click_link "Next day >>" }

        it "should remain on the same feed" do
          page.should have_content "papers from #{feed.name}"
        end

        it "should go to the right date" do
          page.should have_content "#{Date.today.to_formatted_s(:rfc822)}"
        end
      end

      describe "prev button and feeds" do
        before { click_link "<< Prev day" }

        it "should remain on the same feed" do
          page.should have_content "papers from #{feed.name}"
        end

        it "should go to the right date" do
          page.should have_content "#{(Date.yesterday - 1.day).to_formatted_s(:rfc822)}"
        end
      end

      describe "with a date range" do
        before do
          visit papers_path(feed: feed.name, range: 2, date: Date.today)
        end

        it "should have the right heading" do
          page.should have_content "#{(Date.today - 1.day).to_formatted_s(:rfc822)} to #{Date.today.to_formatted_s(:rfc822)}"
        end

        it "should list all papers from feed in the range" do
          feed.papers.each do |paper|
            if [Date.yesterday, Date.today].include? paper.pubdate
              page.should have_link paper.identifier
              page.should have_content paper.title
            else
              page.should_not have_link paper.identifier
              page.should_not have_content paper.title
            end
          end
        end

        it "should not list any papers from default feed" do
          Feed.default.papers.each do |paper|
            page.should_not have_link paper.identifier
            page.should_not have_content paper.title
          end
        end
      end

      describe "with subscriptions" do
        let(:new_user) { FactoryGirl.create(:user) }
        let(:feed1) { FactoryGirl.create(:feed) }
        let(:feed2) { FactoryGirl.create(:feed) }

        before do
          3.times { FactoryGirl.create(:paper, feed: feed1, pubdate: Date.today) }
          3.times { FactoryGirl.create(:paper, feed: feed2, pubdate: Date.today) }

          sign_in(new_user)
          new_user.subscribe!(feed1)

          visit papers_path
        end

        it { should have_content "papers from #{new_user.name}'s feed" }

        it "should list most recent papers from subscribed feed" do
          feed1.papers.find_all_by_pubdate(Date.today).each do |paper|
            page.should have_link paper.identifier
            page.should have_content paper.title
          end
        end

        it "should not list any papers from other feeds" do
          feed2.papers.each do |paper|
            page.should_not have_link paper.identifier
            page.should_not have_content paper.title
          end
        end

        describe "with date range" do
          before do
            3.times { FactoryGirl.create(:paper, feed: feed1, pubdate: Date.yesterday) }
            3.times { FactoryGirl.create(:paper, feed: feed1, pubdate: Date.today - 2.day) }

            visit papers_path(range: 2)
          end

          it "should have the right heading" do
            page.should have_content "#{(Date.today - 1.day).to_formatted_s(:rfc822)} to #{Date.today.to_formatted_s(:rfc822)}"
          end

          it "should list all papers from subscribed feeds in the range" do
            feed1.papers.each do |paper|
              if [Date.yesterday, Date.today].include? paper.pubdate
                page.should have_link paper.identifier
                page.should have_content paper.title
              else
                page.should_not have_link paper.identifier
                page.should_not have_content paper.title
              end
            end
          end

          it "should not list any papers from default feed" do
            feed2.papers.each do |paper|
              page.should_not have_link paper.identifier
              page.should_not have_content paper.title
            end
          end
        end
      end
    end
  end
end
