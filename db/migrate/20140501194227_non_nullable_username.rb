class NonNullableUsername < ActiveRecord::Migration
  def change
    change_column :users, :username, :text, null: false
  end
end
