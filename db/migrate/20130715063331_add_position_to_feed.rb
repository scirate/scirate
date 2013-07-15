class AddPositionToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :position, :integer
  end
end
