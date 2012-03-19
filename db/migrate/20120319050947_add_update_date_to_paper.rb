class AddUpdateDateToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :updated_date, :date
  end
end
