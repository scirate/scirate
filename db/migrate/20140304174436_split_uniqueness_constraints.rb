class SplitUniquenessConstraints < ActiveRecord::Migration
  def change
    add_index :comment_reports, [:user_id, :comment_id], unique: true
    remove_index :feeds, :uid
    add_index :feeds, :uid, unique: true
    add_index :scites, [:paper_uid, :user_id], unique: true
    add_index :subscriptions, [:feed_uid, :user_id], unique: true
    add_index :users, :username, unique: true
    add_index :votes, [:votable_id, :votable_type, :voter_id], unique: true
  end
end
