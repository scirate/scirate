class TripartIndex < ActiveRecord::Migration
  def change
    add_index :categories, [:paper_uid, :feed_uid, :crosslist_date]
  end
end
