class CategoryCrossListDate < ActiveRecord::Migration
  def change
    add_column :categories, :crosslist_date, :datetime, null: false, default: Time.now
  end
end
