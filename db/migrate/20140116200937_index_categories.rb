class IndexCategories < ActiveRecord::Migration
  def change
    add_index :categories, :crosslist_date
    add_index :categories, [:feed_uid, :crosslist_date]
  end
end
