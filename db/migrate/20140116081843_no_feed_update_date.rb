class NoFeedUpdateDate < ActiveRecord::Migration
  def change
    remove_column :feeds, :updated_date
  end
end
