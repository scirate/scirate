require 'spec_helper'

describe CommentsController do

  let(:comment) { FactoryGirl.create(:comment) }
  let(:user)  { comment.user.reload }
  let(:paper) { comment.paper.reload }

  before { sign_in user }

  describe "commenting" do
    it "should post a comment" do
      expect do
        xhr :post, :create, comment: { paper_uid: paper.uid, content: "fishies" }
        response.should be_redirect
        flash[:comment][:status].should == :success
        paper.comments.last.content.should == "fishies"
        paper.reload
      end.to change(paper, :comments_count).by(1)
    end

    it "should edit a comment" do
      xhr :post, :edit, id: comment.id, content: "wubbles"
      response.should be_success
      comment.reload.content.should == "wubbles"
    end

    it "should delete a comment" do
      expect do
        xhr :post, :delete, id: comment.id
        response.should be_redirect
        flash[:comment][:status].should == 'success'
        paper.reload
      end.to change(paper, :comments_count).by(-1)
    end

    it "should reply to a comment" do
      expect do
        xhr :post, :reply, id: comment.id, content: "snuffles"
        response.should be_redirect
        flash[:comment][:status].should == 'success'
        paper.reload

        reply = comment.children[0]
        reply.content.should == "snuffles"
        reply.paper_uid.should == paper.uid
      end.to change(paper, :comments_count).by(1)
    end

    it "should allow a single upvote" do
      expect do 
        xhr :post, :upvote, id: comment.id
        response.should be_success
        xhr :post, :upvote, id: comment.id
        comment.reload
      end.to change(comment, :cached_votes_up).by(1)
    end

    it "should allow a single downvote" do
      expect do 
        xhr :post, :downvote, id: comment.id
        response.should be_success
        xhr :post, :downvote, id: comment.id
        comment.reload
      end.to change(comment, :cached_votes_down).by(1)
    end

    it "should allow unvoting" do
      expect do 
        xhr :post, :upvote, id: comment.id
        response.should be_success
        xhr :post, :unvote, id: comment.id
        response.should be_success
        comment.reload
      end.to_not change(comment, :cached_votes_up)
    end
  end
end
