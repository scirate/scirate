class RemoveIndexPubdateFromFeedDay < ActiveRecord::Migration
  def change
    remove_index :feed_days, :pubdate
    add_index :feed_days, [:pubdate, :feed_name], unique: true
  end
end
