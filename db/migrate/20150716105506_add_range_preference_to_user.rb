class AddRangePreferenceToUser < ActiveRecord::Migration
  def change
    add_column :users, :range_preference, :integer, default: 0
  end
end
