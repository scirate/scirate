class SciteTimestamps < ActiveRecord::Migration
  def change
    change_table :scites do |t|
      t.timestamps
    end
  end
end
