class AccurateTimestampNames < ActiveRecord::Migration
  def change
    rename_column :papers, :pubdate, :submit_date
    rename_column :papers, :updated_date, :update_date
  end
end
