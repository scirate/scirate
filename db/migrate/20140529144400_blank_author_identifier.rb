class BlankAuthorIdentifier < ActiveRecord::Migration
  def change
    change_column :users, :author_identifier, :text, null: false, default: ''
  end
end
