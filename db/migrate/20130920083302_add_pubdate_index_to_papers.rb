class AddPubdateIndexToPapers < ActiveRecord::Migration
  def change
    add_index :papers, :pubdate
  end
end
