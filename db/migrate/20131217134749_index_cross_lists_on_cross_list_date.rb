class IndexCrossListsOnCrossListDate < ActiveRecord::Migration
  def change
    add_index :cross_lists, :cross_list_date
  end
end
