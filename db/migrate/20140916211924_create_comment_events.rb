class CreateCommentEvents < ActiveRecord::Migration
  def change
    create_table :comment_changes do |t|
      t.references :comment, index: true, null: false
      t.references :user, index: true, null: false
      t.text :event, null: false
      t.text :reason, null: false, default: ""
      t.text :content, null: false

      t.timestamps
    end
  end
end
