require 'spec_helper'

describe CommentsController do
  let(:comment) { FactoryGirl.create(:comment) }
  let(:user)  { comment.user.reload }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:paper) { comment.paper.reload }

  describe "posting a comment" do
    before do
      become user
      expect(Net::HTTP).to receive(:start).once.and_return(double(code: '200'))
      xhr :post, :create, comment: { paper_uid: paper.uid, content: "fishies" }
      response.should be_redirect
    end

    it "creates a comment" do
      expect(flash[:comment][:status]).to eq :success

      comment = paper.comments.where(content: "fishies").first
      expect(comment).to_not be_nil
    end
  end

  describe "editing a comment" do
    before do
      become user
      xhr :post, :edit, id: comment.id, content: "wubbles"
    end

    it "edits the comment" do
      expect(response).to be_success
      expect(comment.reload.content).to eq "wubbles"
    end
  end

  describe "deleting a comment" do
    before do
      become user
      xhr :post, :delete, id: comment.id
      expect(response).to be_redirect
    end

    it "marks comment as deleted" do
      flash[:comment][:status].should == 'success'

      expect(comment.reload.deleted).to be_truthy
    end
  end

  describe "restoring a comment" do
    before do
      become user
      comment.deleted = true
      comment.save
      xhr :post, :restore, id: comment.id
      response.should be_redirect
    end

    it "restores the comment" do
      flash[:comment][:status].should == 'success'
      expect(comment.reload.deleted).to be(false)
    end
  end

  describe "replying to a comment" do
    before do
      become user
      xhr :post, :reply, id: comment.id, content: "snuffles"
      response.should be_redirect
    end

    it "creates a new comment in reply" do
      flash[:comment][:status].should == 'success'
      reply = comment.reload.children[0]
      expect(reply.content).to eq "snuffles"
      expect(reply.paper_uid).to eq paper.uid
    end
  end

  describe "voting" do
    before { become other_user }

    it "allows a single upvote" do
      expect do
        xhr :post, :upvote, id: comment.id
        expect(response).to be_success
        xhr :post, :upvote, id: comment.id
        comment.reload
      end.to change(comment, :cached_votes_up).by(1)
    end

    it "allows a single downvote" do
      expect do
        xhr :post, :downvote, id: comment.id
        expect(response).to be_success
        xhr :post, :downvote, id: comment.id
        comment.reload
      end.to change(comment, :cached_votes_down).by(1)
    end

    it "allows unvoting" do
      expect do
        xhr :post, :upvote, id: comment.id
        expect(response).to be_success
        xhr :post, :unvote, id: comment.id
        expect(response).to be_success
        comment.reload
      end.to_not change(comment, :cached_votes_up)
    end
  end
end
