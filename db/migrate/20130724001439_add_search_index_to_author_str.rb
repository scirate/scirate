class AddSearchIndexToAuthorStr < ActiveRecord::Migration
  def up
    execute "drop index papers_to_tsvector_idx2;"
    execute "create index on papers using gin(to_tsvector('english', author_str));"
  end

  def down
    raise
  end
end
