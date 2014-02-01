class SizeShouldBeString < ActiveRecord::Migration
  def change
    remove_column :versions, :size

    add_column :versions, :size, :string
  end
end
