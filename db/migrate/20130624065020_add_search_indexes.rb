class AddSearchIndexes < ActiveRecord::Migration
  def up
    execute "
        create index on papers using gin(to_tsvector('english', title));
        create index on papers using gin(to_tsvector('english', abstract));
    "
  end

  def down
    raise
  end
end
