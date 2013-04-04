class AddStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_status, :string, :default => 'user'
  end
end
