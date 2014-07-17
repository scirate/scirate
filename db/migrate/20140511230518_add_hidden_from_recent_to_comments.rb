class AddHiddenFromRecentToComments < ActiveRecord::Migration
  def change
    add_column :comments, :hidden_from_recent, :boolean, default: false, null: false
  end
end
