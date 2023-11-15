class CommentsController < ApplicationController
  before_action :find_comment, only: [:edit, :delete, :restore, :upvote, :unvote, :report, :unreport, :reply, :history]

  before_action  :check_moderation_permission, only: [:edit, :delete, :restore]

  def index
    @page = [1, params.fetch(:page, 1).to_i].max
    @per_page = 50

    feed_uids = if params[:feed]
      # Comments on papers in a particular feed
      feed_uids = Feed.find_related_uids([params[:feed]])
    elsif signed_in?
      # Comments on papers in the user's home timeline
      sub_uids = current_user.subscriptions.pluck(:feed_uid)
      feed_uids = Feed.find_related_uids(sub_uids)
    end

    query = if feed_uids.nil?
      Comment.joins(:user, :paper)
             .where(deleted: false, hidden: false, hidden_from_recent: false)
    else
      Comment.joins(:user, paper: :categories)
             .where(deleted: false, hidden: false, hidden_from_recent: false)
             .where(categories: { feed_uid: feed_uids })
    end


    @pagination = WillPaginate::Collection.new(@page, @per_page, query.count)

    @comments = query.order('comments.id DESC')
                     .limit(@per_page)
                     .offset((@page-1)*@per_page)
                     .select('DISTINCT ON (comments.id) comments.id',
                             'comments.content',
                             'comments.created_at',
                             'comments.updated_at',
                             'papers.uid AS paper_uid',
                             'papers.title AS paper_title',
                             'users.username AS user_username',
                             'users.fullname AS user_fullname')
  end

  def history
    return check_moderation_permission if @comment.deleted
  end

  def create
    comment_params = params.require(:comment).permit(:paper_uid, :content)

    @comment = current_user.comments.build(comment_params)

    if not(@comment.paper.locked) and not(current_user.is_spammer?)
        @comment.save!
        @comment.submit_trackback
        flash[:comment] = { status: :success, content: "Comment posted." }
    end

    redirect_to @comment.paper
  end

  def edit
    unless @comment.content == params[:content] # Don't record edit if same
      @comment.edit!(params[:content], current_user.id)
    end
    render json: 'success'
  end

  def delete
    # soft delete - hide
    @comment.soft_delete!(current_user.id)

    flash[:comment] = { status: 'success', raw: "Comment deleted. <a data-method='post' href='#{restore_comment_path(@comment.id)}'>(undo)</a>" }

    redirect_to request.referer || @comment.paper
  end

  # Restore a deleted comment
  def restore
    @comment.restore!(current_user.id)

    flash[:comment] = { status: 'success', content: "Comment restored." }
    redirect_to request.referer || @comment.paper
  end

  def upvote
    unless comment_owner?
      @comment.upvote_from(current_user)
      render json: 'success'
    else
      render json: "can't upvote own comment"
    end
  end

  def unvote
    @comment.unvote(voter: current_user)
    render json: 'success'
  end

  def report
    @comment.reports.create(user_id: current_user.id)
    render json: 'success'
  end

  def unreport
    @comment.reports.where(user_id: current_user.id).destroy_all
    render json: 'success'
  end

  def reply
    @reply = current_user.comments.build(
      paper_uid: @comment.paper_uid,
      parent_id: @comment.id,
      ancestor_id: @comment.ancestor_id || @comment.id,
      content: params[:content]
    )

    if not(@comment.paper.locked) and not(current_user.is_spammer?)
        if @reply.save
            flash[:comment] = { status: 'success', content: "Comment posted." }
        else
            flash[:comment] = { status: 'error', content: "Error posting comment." }
        end
    end

    redirect_to @reply.paper
  end

  private

    def check_moderation_permission
      if !signed_in? || (!comment_owner? && !current_user.can_moderate?)
        not_found
      end
    end

    def comment_owner?
      @comment.user_id == current_user.id
    end

    def find_comment
      @comment = Comment.find(params[:id])
    end

    def find_feed_ids(feed)
      feed.children.pluck(:uid) + [feed.uid]
    end
end
