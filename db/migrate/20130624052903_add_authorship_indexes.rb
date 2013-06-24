class AddAuthorshipIndexes < ActiveRecord::Migration
  def up
    add_index :authorships, :paper_id
    add_index :authorships, :author_id
  end

  def down
    remove_index :authorships, :paper_id
    remove_index :authorships, :author_id
  end
end
