class AddAuthorStrToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :author_str, :text
  end
end
