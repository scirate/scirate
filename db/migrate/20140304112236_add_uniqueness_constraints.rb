class AddUniquenessConstraints < ActiveRecord::Migration
  def change
    add_index :categories, [:position, :paper_uid], unique: true
    add_index :categories, [:feed_uid, :paper_uid], unique: true
    remove_index :papers, :uid
    add_index :papers, :uid, unique: true
    add_index :papers, :abs_url, unique: true
    add_index :papers, :pdf_url, unique: true
    add_index :authors, [:position, :paper_uid], unique: true
    add_index :versions, [:position, :paper_uid], unique: true
  end
end
