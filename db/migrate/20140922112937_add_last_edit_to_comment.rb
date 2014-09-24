class AddLastEditToComment < ActiveRecord::Migration
  def change
    add_reference :comments, :last_edit, index: true
  end
end
