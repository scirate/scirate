class RemoveTsvectorIndexes < ActiveRecord::Migration
  def up
    execute "drop index papers_to_tsvector_idx;"
    execute "drop index papers_to_tsvector_idx1;"
    execute "drop index papers_to_tsvector_idx2;"
    execute "drop index papers_to_tsvector_idx3;"
    execute "drop index papers_to_tsvector_idx4;"
  end

  def down
    raise
  end
end
