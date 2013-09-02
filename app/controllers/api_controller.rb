class ApiController < ApplicationController
  before_filter :authorize

  def scite
    @paper = Paper.find(params[:paper_id])
    current_user.scite!(@paper)

    if request.xhr?
      @scited_papers = [@paper]
      render partial: 'scites/toggle', object: @paper, as: :paper
    else
      redirect_to @paper
    end
  end

  def unscite
    @paper = Paper.find(params[:paper_id])
    current_user.unscite!(@paper)

    if request.xhr?
      @scited_papers = []
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

  private
    def authorize
      unless signed_in?
        session[:return_to] = request.fullpath
        render json: { error: 'login_required' }, status: 401
      end
    end
end
