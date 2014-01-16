class AddContentToComment < ActiveRecord::Migration
  def change
    add_column :comments, :content, :text, null: false
  end
end
