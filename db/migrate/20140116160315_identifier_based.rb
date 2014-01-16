class IdentifierBased < ActiveRecord::Migration
  def change
    rename_column :papers, :identifier, :uid

    rename_column :feeds, :identifier, :uid

    remove_column :versions, :paper_id
    add_column :versions, :paper_uid, :string
    add_index :versions, :paper_uid

    remove_column :authors, :paper_id
    add_column :authors, :paper_uid, :string
    add_index :authors, :paper_uid

    remove_column :categories, :paper_id
    add_column :categories, :paper_uid, :string
    add_index :categories, :paper_uid

    rename_column :categories, :category, :feed_uid
  end
end
