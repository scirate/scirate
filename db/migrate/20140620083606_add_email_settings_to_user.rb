class AddEmailSettingsToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_about_replies, :boolean, default: true
    add_column :users, :email_about_comments_on_authored, :boolean, default: true
    add_column :users, :email_about_comments_on_scited, :boolean, default: false
  end
end
