class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :identifier
      t.string :keyname
      t.string :forenames
      t.string :affiliation
      t.string :suffix

      t.timestamps
    end
  end
end
