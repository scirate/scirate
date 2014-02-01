class FeedParentUids < ActiveRecord::Migration
  def change
    remove_column :feeds, :parent_id, :integer
    add_column :feeds, :parent_uid, :text, null: true
  end
end
