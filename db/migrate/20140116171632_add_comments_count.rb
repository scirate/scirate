class AddCommentsCount < ActiveRecord::Migration
  def change
    add_column :papers, :comments_count, :integer, null: false, default: 0
  end
end
