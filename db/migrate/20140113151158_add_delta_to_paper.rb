class AddDeltaToPaper < ActiveRecord::Migration
  def change
      add_column :papers, :delta, :boolean, :default => true, :null => false
  end
end
