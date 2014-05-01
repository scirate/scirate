class RemoveProviderFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :provider
    remove_column :users, :uid
    remove_column :users, :oauth_token
    remove_column :users, :oauth_expires_at
  end
end
