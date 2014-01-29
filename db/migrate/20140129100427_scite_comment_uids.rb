class SciteCommentUids < ActiveRecord::Migration
  def change
    add_column :scites, :paper_uid, :text, null: false, default: ""
    add_column :comments, :paper_uid, :text, null: false, default: ""
  end
end
