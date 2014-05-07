class AddAuthToAuthLinks < ActiveRecord::Migration
  def change
    add_column :auth_links, :auth, :text, null: false
  end
end
