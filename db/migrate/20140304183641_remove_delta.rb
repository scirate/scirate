class RemoveDelta < ActiveRecord::Migration
  def change
    remove_column :papers, :delta
    remove_column :comments, :delta
  end
end
