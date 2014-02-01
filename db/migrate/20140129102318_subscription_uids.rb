class SubscriptionUids < ActiveRecord::Migration
  def change
    add_column :subscriptions, :feed_uid, :text, null: false, default: ""
  end
end
