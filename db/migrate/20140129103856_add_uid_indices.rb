class AddUidIndices < ActiveRecord::Migration
  def change
    add_index :scites, :paper_uid
    add_index :comments, :paper_uid
    add_index :subscriptions, :feed_uid
  end
end
