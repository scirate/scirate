class AddPubdate < ActiveRecord::Migration
  def change
    add_column :papers, :pubdate, :datetime
    add_index :papers, :pubdate
  end
end
