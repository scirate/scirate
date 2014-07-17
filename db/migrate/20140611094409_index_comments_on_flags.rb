class IndexCommentsOnFlags < ActiveRecord::Migration
  def change
    add_index :comments, :deleted
    add_index :comments, :hidden
    add_index :comments, :hidden_from_recent
  end
end
