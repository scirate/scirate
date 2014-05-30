class RenameAffiliationToOrganization < ActiveRecord::Migration
  def change
    rename_column :users, :affiliation, :organization
  end
end
