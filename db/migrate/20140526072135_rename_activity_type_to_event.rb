class RenameActivityTypeToEvent < ActiveRecord::Migration
  def change
    rename_column :activities, :type, :event
  end
end
