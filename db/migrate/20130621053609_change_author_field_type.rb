class ChangeAuthorFieldType < ActiveRecord::Migration
  def up
    change_column :authors, :forenames, :text, :limit => nil
    change_column :authors, :affiliation, :text, :limit => nil
    change_column :authors, :fullname, :text, :limit => nil
  end

  def down
    change_column :authors, :forenames, :string
    change_column :authors, :affiliation, :string
    change_column :authors, :fullname, :string
  end
end
