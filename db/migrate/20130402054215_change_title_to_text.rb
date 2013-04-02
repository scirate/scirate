class ChangeTitleToText < ActiveRecord::Migration
  def up
    change_column :papers, :title, :text
  end

  def down
    change_column :papers, :title, :string
  end
end
