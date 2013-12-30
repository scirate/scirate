class DenormalizeAuthorsAgain < ActiveRecord::Migration
  def change
    add_column :authorships, :keyname, :text
    add_column :authorships, :forenames, :text
    add_column :authorships, :affiliation, :text
    add_column :authorships, :suffix, :text
    add_column :authorships, :searchterm, :text
    add_column :authorships, :fullname, :text
  end
end
