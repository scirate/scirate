class AddVersionsCountToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :versions_count, :integer, null: false, default: 1
  end
end
