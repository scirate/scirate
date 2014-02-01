class VersionNotNull2 < ActiveRecord::Migration
  def change
    add_column :versions, :paper_uid, :string, null: false
  end
end
