class CommentDeletionMark < ActiveRecord::Migration
  def change
    add_column :comments, :deleted, :boolean, null: false, default: false
  end
end
