class UpdateTrackers < ActiveRecord::Migration
  def change
    add_column :system, :arxiv_sync_dt, :datetime, null: false, default: Time.now.utc.beginning_of_day-1.days
    add_column :system, :arxiv_author_sync_dt, :datetime, null: false, default: Time.now.utc.beginning_of_day-1.days
  end
end
