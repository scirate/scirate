class SubscriptionsController < ApplicationController
  before_filter :signed_in_user

  def create
    @feed = Feed.find(params[:subscription][:feed_id])
    current_user.subscribe!(@feed)

    respond_to do |format|
      format.html { redirect_to(:back) }
      format.js
    end
  end

  def destroy    
    @feed = Subscription.find(params[:id]).feed
    current_user.unsubscribe!(@feed)

    respond_to do |format|
      format.html { redirect_to(:back) }
      format.js
    end
  end
end
