class AddSubscriptionCacheToUsers < ActiveRecord::Migration
  def change
    add_column :users,  :subscriptions_count, :integer, default: 0

    User.reset_column_information
    User.find(:all).each do |u|
      User.update_counters u.id, subscriptions_count: u.subscriptions.count
    end
  end
end
