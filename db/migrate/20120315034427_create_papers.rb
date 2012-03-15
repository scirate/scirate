class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.string :title
      t.text :authors
      t.text :abstract
      t.string :identifier
      t.string :url

      t.timestamps
    end
  end
end
