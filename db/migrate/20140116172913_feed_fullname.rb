class FeedFullname < ActiveRecord::Migration
  def change
    rename_column :feeds, :name, :fullname
  end
end
