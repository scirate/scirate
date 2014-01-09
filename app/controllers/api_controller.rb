class ApiController < ApplicationController
  before_filter :authorize

  def scite
    @paper = Paper.find(params[:paper_id])
    current_user.scite!(@paper)

    if request.xhr?
      @scited_ids = [@paper.id]
      render partial: 'scites/toggle', object: @paper, as: :paper
    else
      redirect_to @paper
    end
  end

  def unscite
    @paper = Paper.find(params[:paper_id])
    current_user.unscite!(@paper)

    if request.xhr?
      @scited_ids = []
      render partial: 'scites/toggle', object: @paper, as: :paper
    else
      redirect_to @paper
    end
  end

  def subscribe
    @feed = Feed.find(params[:feed_id])
    @feed.subscriptions.find_or_create_by(user_id: current_user.id)
    if request.xhr?
      render :partial => 'feeds/subscribe', :locals => { :feed => @feed }
    else
      redirect_to @feed
    end
  end

  def unsubscribe
    @feed = Feed.find(params[:feed_id])
    @feed.subscriptions.where(user_id: current_user.id).destroy_all
    if request.xhr?
      render :partial => 'feeds/subscribe', :locals => { :feed => @feed }
    else
      redirect_to @feed
    end
  end

  def resend_confirm
    current_user.send_signup_confirmation
    render json: { success: true }
  end

  # Retrieve or update misc. user account settings
  def settings
    settings = [:expand_abstracts]

    if request.post?
      current_user.update!(params.permit(*settings))
    end

    render json: current_user.slice(*settings)
  end

  private
    def authorize
      unless signed_in?
        session[:return_to] = request.fullpath
        render json: { error: 'login_required' }, status: 401
      end
    end
end
