class AddExpandAbstracts < ActiveRecord::Migration
  def change
    add_column :users, :expand_abstracts, :boolean, default: false
  end
end
