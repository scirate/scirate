class DropFeedDays < ActiveRecord::Migration
  def change
    drop_table :feed_days
  end
end
