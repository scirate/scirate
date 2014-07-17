class AddPapersCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :papers_count, :integer, null: false, default: 0
  end
end
