class AddWebsiteAndLocationToUser < ActiveRecord::Migration
  def change
    add_column :users, :url, :text, null: false, default: ''
    add_column :users, :location, :text, null: false, default: ''
  end
end
