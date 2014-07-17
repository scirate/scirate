class RenameUserAuthorToAuthorship < ActiveRecord::Migration
  def change
    rename_table :user_authors, :authorships
  end
end
