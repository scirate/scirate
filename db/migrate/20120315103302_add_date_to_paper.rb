class AddDateToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :date, :date

    add_index :papers, :identifier, unique: true
    add_index :papers, :date
  end
end
