class AddSearchIndices < ActiveRecord::Migration
  def up
    execute "
      CREATE INDEX ON papers USING gin(to_tsvector('english', title));
      CREATE INDEX ON papers USING gin(to_tsvector('english', authors));"
  end

  def down
  end
end
