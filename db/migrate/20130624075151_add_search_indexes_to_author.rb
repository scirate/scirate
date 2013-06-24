class AddSearchIndexesToAuthor < ActiveRecord::Migration
  def up
    execute "
        create index on authors using gin(to_tsvector('english', fullname));
    "
  end

  def down
    raise
  end
end
