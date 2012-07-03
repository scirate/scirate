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
    @recent_comments = Comment.includes(:paper, :user).limit(100).find(:all, order: "created_at DESC")
  end

end
