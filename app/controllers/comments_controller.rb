class CommentsController < ApplicationController
  before_filter :find_comment, :only => [:edit, :delete, :upvote, :downvote, :unvote, :report, :unreport, :reply]

  def index
    if params[:feed]
      @feed = Feed.find_by_uid!(params[:feed])
      comments = Comment.find_by_feed_uids([@feed.uid])
    else
      feeds = current_user.feeds.includes(:children)
      feed_uids = feeds.map(&:uid) + feeds.map(&:children).flatten.map(&:uid)
      comments = Comment.find_by_feed_uids(feed_uids)
    end

    @comments = comments.paginate(page: params[:page]||1)
  end

  def create
    @comment = current_user.comments.build(
      paper_uid: params[:comment][:paper_uid],
      content: params[:comment][:content]
    )
    
    if @comment.save
      flash[:comment] = { status: :success, content: "Comment posted." }
    else
      flash[:comment] = { status: :error, content: "Error posting comment." }
    end

    redirect_to @comment.paper
  end

  def edit
    if @comment.user_id == current_user.id || current_user.is_moderator?
      @comment.content = params[:content]
      @comment.save
      render :text => 'success'
    else
      render :status => :forbidden
    end
  end

  def delete
    paper = @comment.paper
    if @comment.user_id == current_user.id || current_user.is_moderator?

      if @comment.children.length == 0
        # If this comment has no replies, remove it completely
        @comment.destroy
      else
        # Otherwise, just hide it away
        @comment.deleted = true
        @comment.save
        paper.comments_count -= 1
        paper.save
      end

      flash[:comment] = { status: 'success', content: "Comment deleted." }
      redirect_to request.referer || paper
    else
      render :status => :forbidden
    end
  end

  def upvote
    if current_user.id != @comment.user_id
      @comment.upvote_from(current_user)
      render :text => 'success'
    else
      render :text => "can't upvote own comment"
    end
  end

  def downvote
    if current_user.id != @comment.user_id
      @comment.downvote_from(current_user)
      render :text => 'success'
    else
      render :text => "can't downvote own comment"
    end
  end

  def unvote
    @comment.unvote(voter: current_user)
    render :text => 'success'
  end

  def report
    @comment.reports.create(:user_id => current_user.id)
    render :text => 'success'
  end

  def unreport
    @comment.reports.where(voter_id: current_user.id).destroy_all
    render :text => 'success'
  end

  def reply
    @reply = current_user.comments.build(
      paper_uid: @comment.paper_uid,
      parent_id: @comment.id,
      ancestor_id: @comment.ancestor_id || @comment.id,
      content: params[:content]
    )

    @reply.save!

    if @reply.save
      flash[:comment] = { status: 'success', content: "Comment posted." }
    else
      flash[:comment] = { status: 'success', content: "Error posting comment." }
    end

    redirect_to @reply.paper
  end

  protected
    def find_comment
      @comment = Comment.find(params[:id])
    end
end
