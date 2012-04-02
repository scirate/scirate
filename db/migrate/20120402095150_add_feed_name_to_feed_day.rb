class AddFeedNameToFeedDay < ActiveRecord::Migration
  def change
    add_column :feed_days, :feed_name, :string
  end
end
