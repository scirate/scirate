class AddSearchtermToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :searchterm, :string
    remove_column :authors, :identifier
  end
end
