class CreateFeedDays < ActiveRecord::Migration
  def change
    create_table :feed_days do |t|
      t.date :pubdate
      t.text :content

      t.timestamps
    end

    add_index :feed_days, :pubdate, unique: true
  end
end
