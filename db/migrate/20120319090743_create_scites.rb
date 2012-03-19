class CreateScites < ActiveRecord::Migration
  def change
    create_table :scites do |t|
      t.integer :sciter_id
      t.integer :paper_id

      t.timestamps
    end

    add_index :scites, :sciter_id
    add_index :scites, :paper_id
    add_index :scites, [:sciter_id, :paper_id], unique: true
  end
end
