class AddPositionToAuthorship < ActiveRecord::Migration
  def change
    add_column :authorships, :position, :integer
  end
end
