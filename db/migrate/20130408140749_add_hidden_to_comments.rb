class AddHiddenToComments < ActiveRecord::Migration
  def change
    add_column :comments, :hidden, :boolean
  end
end
