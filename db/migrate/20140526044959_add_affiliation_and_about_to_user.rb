class AddAffiliationAndAboutToUser < ActiveRecord::Migration
  def change
    add_column :users, :affiliation, :text, null: false, default: ''
    add_column :users, :about, :text, null: false, default: ''
  end
end
