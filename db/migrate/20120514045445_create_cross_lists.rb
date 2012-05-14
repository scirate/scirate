class CreateCrossLists < ActiveRecord::Migration
  def change
    create_table :cross_lists do |t|
      t.integer :paper_id
      t.integer :feed_id
      t.date :cross_list_date

      t.timestamps
    end

    add_index :cross_lists, :paper_id
    add_index :cross_lists, :feed_id
    add_index :cross_lists, [:feed_id, :cross_list_date]
    add_index :cross_lists, [:paper_id, :feed_id], unique: true
  end
end
