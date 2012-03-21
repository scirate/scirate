class AddConfirmationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :active, :boolean, default: false

    User.reset_column_information
    User.all.each do |u|
      u.update_attribute(:active, true)
    end
  end
end
