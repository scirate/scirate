class ApiController < ApplicationController
  before_filter :authorize
  before_filter :needs_moderator, only: [:hide_from_recent]

  def scite
    @paper = Paper.find_by_uid!(params[:paper_uid])
    current_user.scite!(@paper)

    if request.xhr?
      render json: true
    else
      redirect_to @paper
    end
  end

  def unscite
    @paper = Paper.find_by_uid!(params[:paper_uid])
    current_user.unscite!(@paper)

    if request.xhr?
      render json: true
    else
      redirect_to @paper
    end
  end

  def subscribe
    @feed = Feed.find_by_uid!(params[:feed_uid])
    current_user.subscribe!(@feed)
    if request.xhr?
      render json: true
    else
      redirect_to @feed
    end
  end

  def unsubscribe
    @feed = Feed.find_by_uid!(params[:feed_uid])
    current_user.unsubscribe!(@feed)
    if request.xhr?
      render json: true
    else
      redirect_to @feed
    end
  end

  def resend_confirm
    current_user.send_signup_confirmation
    render json: { success: true }
  end

  def download_scites
    render json: current_user.scited_papers
  end

  # Retrieve or update misc. user account settings
  def settings
    settings = [:expand_abstracts]

    if request.post?
      current_user.update!(params.permit(*settings))
    end

    render json: current_user.slice(*settings)
  end

  def hide_from_recent
    comment = Comment.find_by_id!(params[:comment_id])

    comment.hidden_from_recent = true
    comment.save!

    render json: { success: true }
  end

  private
    def authorize
      unless signed_in?
        session[:return_to] = request.fullpath
        render json: { error: 'login_required' }, status: 401
      end
    end

    def needs_moderator
      unless signed_in? && current_user.can_moderate?
        render json: { error: 'unauthorized' }, status: 403
      end
    end
end
