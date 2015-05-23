class AddEmailAboutReportedCommentsToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_about_reported_comments, :boolean, default: false
  end
end
