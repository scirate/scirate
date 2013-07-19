class AddSearchtermIndexToAuthor < ActiveRecord::Migration
  def up
    execute "
        create index on authors using gin(to_tsvector('english', searchterm));
    "
  end

  def down
    raise
  end
end
