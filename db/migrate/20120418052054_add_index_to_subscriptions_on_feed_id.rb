class AddIndexToSubscriptionsOnFeedId < ActiveRecord::Migration
  def change
    add_index :subscriptions, :feed_id
  end
end
