require 'spec_helper'

describe CommentsController do

  let(:user)  { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:comment) { FactoryGirl.create(:comment) }

  before { sign_in user }

  describe "upvoting a comment" do
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
