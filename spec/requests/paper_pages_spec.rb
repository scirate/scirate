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

    describe "scite/unscite buttons" do
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

  describe "index" do
    let(:paper) { FactoryGirl.create(:paper, pubdate: Date.today) }
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    before do
      visit papers_path(date: Date.today)
    end

    it { should have_title "Papers from #{Date.today.to_formatted_s(:short)}" }

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

    describe "pagination" do
      before(:all) do
        30.times { FactoryGirl.create(:paper, pubdate: Date.today) }
        30.times { FactoryGirl.create(:paper, pubdate: Date.yesterday) }
        30.times { FactoryGirl.create(:paper, pubdate: Date.yesterday - 1) }
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

      it "should have the right links to the next/prev days" do
        page.should have_link Date.yesterday.to_formatted_s(:short)
        page.should_not have_link Date.tomorrow.to_formatted_s(:short)
      end

      describe "on previous day's page" do
        before { visit papers_path(date: Date.yesterday) }

        it "should have the right links to the next/prev days" do
          page.should have_link Date.yesterday.prev_day.to_formatted_s(:short)
          page.should have_link Date.today.to_formatted_s(:short)
        end
      end

      describe "on page from two days ago" do
        before { visit papers_path(date: Date.yesterday.prev_day) }

        it "should have the right links to the next/prev days" do
          page.should_not have_link Date.yesterday.prev_day.prev_day.to_formatted_s(:short)
          page.should have_link Date.yesterday.to_formatted_s(:short)
        end
      end
    end
  end
end
