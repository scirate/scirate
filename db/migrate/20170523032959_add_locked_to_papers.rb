class AddLockedToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :locked, :boolean, default: false, null: false
  end
end
