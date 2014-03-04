class RemoveOldTables < ActiveRecord::Migration
  def change
    drop_table :delayed_jobs
    drop_table :down_votes
    drop_table :downvotes
    drop_table :feed_days
    drop_table :up_votes
    drop_table :upvotes
  end
end
