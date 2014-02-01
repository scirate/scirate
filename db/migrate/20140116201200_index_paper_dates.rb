class IndexPaperDates < ActiveRecord::Migration
  def change
    add_index :papers, :scites_count
    add_index :papers, :comments_count
    add_index :papers, :submit_date
    add_index :papers, [:scites_count, :comments_count, :submit_date]
  end
end
