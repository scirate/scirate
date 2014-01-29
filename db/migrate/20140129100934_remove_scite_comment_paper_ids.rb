class RemoveSciteCommentPaperIds < ActiveRecord::Migration
  def change
    remove_column :scites, :paper_id
    remove_column :comments, :paper_id
  end
end
