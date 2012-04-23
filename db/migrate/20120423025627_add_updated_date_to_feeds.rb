class AddUpdatedDateToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :updated_date, :date
  end
end
