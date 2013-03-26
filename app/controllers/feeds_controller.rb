class FeedsController < ApplicationController
  before_filter :find_feed, :only => [:subscribe, :unsubscribe]

  def subscribe
    @feed.subscriptions.create(user_id: current_user.id)
    render :partial => 'subscribe'
  end

  def unsubscribe
    @feed.subscriptions.find_by_user_id(current_user.id).destroy
    render :partial => 'subscribe'
  end

  protected
    def find_feed
      @feed = Feed.find(params[:id])
    end
end
