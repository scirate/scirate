class PaperRenameDateToPubdate < ActiveRecord::Migration
  def up
    rename_column :papers, :date, :pubdate
  end

  def down
    rename_column :papers, :pubdate, :date
  end
end
