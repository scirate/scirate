class AddUniqidToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :uniqid, :string
  end
end
