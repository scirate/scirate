class CommentsController < ApplicationController

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

  def upvote
    comment = Comment.find(params[:id])
    comment.upvote_from(current_user)
    render :text => 'success'
  end

  def downvote
    comment = Comment.find(params[:id])
    comment.downvote_from(current_user)
    render :text => 'success'
  end
end
