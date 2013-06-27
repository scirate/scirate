class UnhideCommentsDefault < ActiveRecord::Migration
  def up
    remove_column :comments, :hidden
    add_column :comments, :hidden, :boolean, :default => false
  end

  def down
  end
end
