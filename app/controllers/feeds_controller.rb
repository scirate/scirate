class FeedsController < ApplicationController
  before_filter :find_feed, :only => [:subscribe, :unsubscribe]

  def subscribe
    @feed.subscriptions.find_or_create_by_user_id(current_user.id)
    render :partial => 'subscribe'
  end

  def unsubscribe
    @feed.subscriptions.where(user_id: current_user.id).destroy_all
    render :partial => 'subscribe'
  end

  protected
    def find_feed
      @feed = Feed.find(params[:id])
    end
end
