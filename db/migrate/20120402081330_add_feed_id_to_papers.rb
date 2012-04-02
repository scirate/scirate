class AddFeedIdToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :feed_id, :integer
  end
end
