class AddSubscriberCacheToFeed < ActiveRecord::Migration
  def change
    add_column :feeds,  :subscriptions_count, :integer, default: 0

    Feed.reset_column_information
    Feed.find(:all).each do |f|
      Feed.update_counters f.id, subscriptions_count: f.subscriptions.count
    end
  end
end
