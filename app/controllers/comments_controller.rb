class CommentsController < ApplicationController
  before_filter :find_comment, :only => [:destroy, :upvote, :downvote, :unvote]

  def create
    @comment = current_user.comments.build(params[:comment])

    if @comment.save
      flash[:success] = "Comment posted."
    else
      flash[:error] = "Error posting comment."
    end

    redirect_to @comment.paper
  end

  def index
    @comments = Comment.paginate(page: params[:page]).includes(:paper, :user).find(:all, order: "created_at DESC")
  end

  def destroy
    if @comment.user_id == current_user.id
      @comment.delete
    end
    redirect_to request.referer
  end

  def upvote
    @comment.upvote_from(current_user)
    render :text => 'success'
  end

  def downvote
    @comment.downvote_from(current_user)
    render :text => 'success'
  end

  def unvote
    @comment.votes.find_by_voter_id(current_user.id).delete
    render :text => 'success'
  end

  protected
    def find_comment
      @comment = Comment.find(params[:id])
    end
end
