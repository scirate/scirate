class IndexDeltas < ActiveRecord::Migration
  def change
    add_index :papers, :delta
  end
end
