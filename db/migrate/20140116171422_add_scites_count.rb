class AddScitesCount < ActiveRecord::Migration
  def change
    add_column :papers, :scites_count, :integer, null: false, default: 0
  end
end
