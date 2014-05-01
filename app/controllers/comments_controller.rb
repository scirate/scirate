class CommentsController < ApplicationController
  before_filter :find_comment, only: [:edit, :delete, :restore, :upvote, :downvote, :unvote, :report, :unreport, :reply]

  before_filter :check_moderation_permission, only: [:edit, :delete, :restore]

  def index
    if params[:feed]
      @feed = Feed.find_by_uid!(params[:feed])
      feed_uids = find_feed_ids(@feed)
      comments = Comment.find_all_by_feed_uids(feed_uids)
    elsif signed_in?
      feeds = current_user.feeds.includes(:children)
      feed_uids = feeds.map { |feed| find_feed_ids(feed) }.flatten
      comments = Comment.find_all_by_feed_uids(feed_uids)
    else
      comments = Comment.active.visible
    end

    @comments = comments.order('created_at DESC').paginate(page: page_params)
  end

  def create
    @comment = current_user.comments.build(comment_params)

    if @comment.save
      flash[:comment] = { status: :success, content: "Comment posted." }
    else
      flash[:comment] = { status: :error, content: "Error posting comment." }
    end

    redirect_to @comment.paper
  end

  def edit
    @comment.content = params[:content]
    @comment.save!
    render text: 'success'
  end

  def delete
    # soft delete - hide
    @comment.soft_delete

    flash[:comment] = { status: 'success', raw: "Comment deleted. <a data-method='post' href='#{restore_comment_path(@comment.id)}'>(undo)</a>" }

    redirect_to request.referer || @comment.paper
  end

  # Restore a deleted comment
  def restore
    @comment.restore

    flash[:comment] = { status: 'success', content: "Comment restored." }
    redirect_to request.referer || @comment.paper
  end

  def upvote
    unless comment_owner?
      @comment.upvote_from(current_user)
      render text: 'success'
    else
      render text: "can't upvote own comment"
    end
  end

  def downvote
    unless comment_owner?
      @comment.downvote_from(current_user)
      render text: 'success'
    else
      render text: "can't downvote own comment"
    end
  end

  def unvote
    @comment.unvote(voter: current_user)
    render text: 'success'
  end

  def report
    @comment.reports.create(user_id: current_user.id)
    render text: 'success'
  end

  def unreport
    @comment.reports.where(user_id: current_user.id).destroy_all
    render text: 'success'
  end

  def reply
    @reply = current_user.comments.build(
      paper_uid: @comment.paper_uid,
      parent_id: @comment.id,
      ancestor_id: @comment.ancestor_id || @comment.id,
      content: params[:content]
    )

    if @reply.save
      flash[:comment] = { status: 'success', content: "Comment posted." }
    else
      flash[:comment] = { status: 'error', content: "Error posting comment." }
    end

    redirect_to @reply.paper
  end

  private

    def check_moderation_permission
      if !comment_owner? && !current_user.is_moderator?
        render status: :forbidden and return
      end
    end

    def comment_owner?
      @comment.user_id == current_user.id
    end

    def find_comment
      @comment = Comment.find(params[:id])
    end

    def page_params
      params.fetch(:page, 1)
    end

    def comment_params
      params.require(:comment).permit(:paper_uid, :content)
    end

    def find_feed_ids(feed)
      feed.children.pluck(:uid) + [feed.uid]
    end
end
