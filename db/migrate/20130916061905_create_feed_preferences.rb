class CreateFeedPreferences < ActiveRecord::Migration
  def change
    create_table :feed_preferences do |t|
      t.integer :user_id
      t.integer :feed_id
      t.timestamp :last_visited
      t.timestamp :previous_last_visited
      t.integer :selected_range

      t.timestamps
    end
  end
end
