class AddNeedsAuthorshipUpdateToUser < ActiveRecord::Migration
  def change
    add_column :users, :needs_authorship_update, :boolean, default: false
  end
end
