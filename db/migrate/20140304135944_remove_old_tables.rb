class RemoveOldTables < ActiveRecord::Migration
  def up
    drop_table :delayed_jobs if table_exists? :delayed_jobs
    drop_table :down_votes if table_exists? :down_votes
    drop_table :downvotes if table_exists? :downvotes
    drop_table :feed_days if table_exists? :feed_days
    drop_table :up_votes if table_exists? :up_votes
    drop_table :upvotes if table_exists? :upvotes
  end

  def down
    raise
  end
end
