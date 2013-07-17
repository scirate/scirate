class AddAncestorIdToComment < ActiveRecord::Migration
  def change
    add_column :comments, :ancestor_id, :integer
  end
end
