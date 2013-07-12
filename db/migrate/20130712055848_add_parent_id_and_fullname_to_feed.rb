class AddParentIdAndFullnameToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :fullname, :text
    add_column :feeds, :parent_id, :integer
  end
end
