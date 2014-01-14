class AddUsernameToExistingUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.username = user.name.downcase.gsub(' ', '.')
      user.save
    end
  end

  def down
    raise
  end
end
