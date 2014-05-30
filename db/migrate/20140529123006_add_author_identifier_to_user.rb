class AddAuthorIdentifierToUser < ActiveRecord::Migration
  def change
    add_column :users, :author_identifier, :text
  end
end
