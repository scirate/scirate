class IndexComments < ActiveRecord::Migration
  def change
    add_index :comments, [:id, :paper_uid, :deleted, :hidden, :hidden_from_recent], name: "index_comments_for_recent"
  end
end
