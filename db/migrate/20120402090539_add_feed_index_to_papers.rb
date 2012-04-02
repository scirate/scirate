class AddFeedIndexToPapers < ActiveRecord::Migration
  def change
    add_index :papers, :feed_id
  end
end
