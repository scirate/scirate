class LastEditToLastChange < ActiveRecord::Migration
  def change
    remove_column :comments, :last_edit_id
    add_reference :comments, :last_change, index: true
  end
end
