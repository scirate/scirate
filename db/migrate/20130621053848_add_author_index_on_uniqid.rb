class AddAuthorIndexOnUniqid < ActiveRecord::Migration
  def up
    add_index :authors, :fullname
    add_index :authors, :searchterm
    add_index :authors, :uniqid
  end

  def down
  end
end
