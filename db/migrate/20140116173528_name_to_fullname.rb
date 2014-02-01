class NameToFullname < ActiveRecord::Migration
  def change
    rename_column :users, :name, :fullname
  end
end
