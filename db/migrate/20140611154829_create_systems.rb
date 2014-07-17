class CreateSystems < ActiveRecord::Migration
  def change
    create_table :system do |t|
      t.text :alert

      t.timestamps
    end
  end
end
