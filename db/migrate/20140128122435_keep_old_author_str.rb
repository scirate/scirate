class KeepOldAuthorStr < ActiveRecord::Migration
  def change
    add_column :papers, :author_str, :text, null: false
  end
end
