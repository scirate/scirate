class SubscriptionsController < ApplicationController
  before_filter :signed_in_user

  def update
    #if no boxes are checked, no feed_ids are passed in
    if params[:feed_ids].nil?
      feed_ids = []
    else
      feed_ids = params[:feed_ids].map { |s| Integer(s) }
    end

    #wipe out the old subsciptions
    current_user.subscriptions.destroy_all

    #create a new subscription for each feed sent in
    feed_ids.each do |feed_id|
      current_user.subscriptions.create(feed_id: feed_id)
    end

    flash[:success] = "Your subscriptions have been updated."
    redirect_to(:back)
  end
end
