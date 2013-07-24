class AddSearchIndexToAuthorStr < ActiveRecord::Migration
  def up
    execute "create index on papers using gin(to_tsvector('english', author_str));"
  end

  def down
    raise
  end
end
