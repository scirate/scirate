class MakeAlertsNonNullable < ActiveRecord::Migration
  def change
    change_column :system, :alert, :text, null: false, default: ''
  end
end
