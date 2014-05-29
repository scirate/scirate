class CreateUserAuthors < ActiveRecord::Migration
  def change
    create_table :user_authors do |t|
      t.references :user, null: false
      t.text :paper_uid, null: false

      t.timestamps
    end
  end
end
