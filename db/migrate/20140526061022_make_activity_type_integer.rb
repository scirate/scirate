class MakeActivityTypeInteger < ActiveRecord::Migration
  def change
    remove_column :activities, :type
    add_column :activities, :type, :integer, null: false
  end
end
