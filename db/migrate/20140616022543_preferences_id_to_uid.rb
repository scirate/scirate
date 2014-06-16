class PreferencesIdToUid < ActiveRecord::Migration
  def change
    remove_column :feed_preferences, :feed_id
    add_column :feed_preferences, :feed_uid, :text
  end
end
