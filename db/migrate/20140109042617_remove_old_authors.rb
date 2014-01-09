class RemoveOldAuthors < ActiveRecord::Migration
  def change
    remove_column :authorships, :author_id
    drop_table :authors
  end
end
