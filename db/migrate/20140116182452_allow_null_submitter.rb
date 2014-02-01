class AllowNullSubmitter < ActiveRecord::Migration
  def change
    change_column :papers, :submitter, :string, null: :true
  end
end
