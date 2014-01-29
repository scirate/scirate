class SubscriptionUidsData < ActiveRecord::Migration
  def change
    Subscription.all.each do |sub|
      sub.feed_uid = Feed.find(sub.feed_id).uid
      sub.save
    end
  end
end
