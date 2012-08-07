require 'spec_helper'

describe "Comment pages" do

  subject { page }

  describe "index" do
    let(:comment) { FactoryGirl.create(:comment) }

    before do
      visit comments_path
    end

    it { should have_title "Comments on all papers" }

    describe "it should list all comments" do
      before do
        comment.save
        visit comments_path
      end

      it { should have_comment comment }
    end

    describe "should sanitize comments" do
      describe "and not allow links" do
        before do
          comment.content = '<a href="http://google.com">spam link</a>'
          comment.save
          visit comments_path
        end

        it { should_not have_link "spam link" }
      end

      describe "and not allow markup" do
        before do
          comment.content = '<h1>Heading in Comment</h1>'
          comment.save
          visit comments_path
        end

        it { should_not have_heading "Heading in Comment" }
      end
    end

    describe "pagination with many comments" do
      before(:all) do
        FactoryGirl.create_list(:comment, 10, content: "First Batch")
        FactoryGirl.create_list(:comment, 10, content: "Second Batch")
      end
      after(:all) do
        Comment.delete_all
        Paper.delete_all
        User.delete_all
      end

      describe "first page" do
        before do
          visit comments_path
        end

        it "should list second 10 comments but not first 10" do
          Comment.all.each do |comment|
            if comment.content == "Second Batch"
              page.should have_comment comment
            else
              page.should_not have_comment comment
            end
          end
        end
      end

      describe "second page" do
        before do
          visit comments_path(page: 2)
        end

        it "should list first 10 comments but not second 10" do
          Comment.all.each do |comment|
            if comment.content == "First Batch"
              page.should have_comment comment
            else
              page.should_not have_comment comment
            end
          end
        end
      end
    end
  end
end
