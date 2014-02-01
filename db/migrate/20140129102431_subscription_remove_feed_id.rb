class SubscriptionRemoveFeedId < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :feed_id
  end
end
