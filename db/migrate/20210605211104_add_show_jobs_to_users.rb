class AddShowJobsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :show_jobs, :boolean, default: true, null: false
  end
end
