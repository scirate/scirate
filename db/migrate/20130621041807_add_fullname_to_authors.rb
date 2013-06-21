class AddFullnameToAuthors < ActiveRecord::Migration
  def up
    add_column :authors, :fullname, :string

    Author.reset_column_information

    Author.all.each do |a|
      a.fullname = Author.make_fullname(a)
      a.save!
    end
  end

  def down
    remove_column :authors, :fullname
  end
end
