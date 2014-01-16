class VersionNotNull < ActiveRecord::Migration
  def change
    remove_column :versions, :paper_uid
  end
end
