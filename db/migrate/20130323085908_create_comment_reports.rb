class CreateCommentReports < ActiveRecord::Migration
  def change
    create_table :comment_reports do |t|
      t.integer :user_id
      t.integer :comment_id

      t.timestamps
    end
  end
end
