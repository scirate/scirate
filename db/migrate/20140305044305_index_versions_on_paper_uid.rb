class IndexVersionsOnPaperUid < ActiveRecord::Migration
  def change
    add_index :versions, :paper_uid
  end
end
