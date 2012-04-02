class FeedRenameTypeToFeedType < ActiveRecord::Migration
  def change
    rename_column :feeds, :type, :feed_type
  end
end
