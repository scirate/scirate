class CommentsToAuthorComments < ActiveRecord::Migration
  def change
    rename_column :papers, :comments, :author_comments
  end
end
