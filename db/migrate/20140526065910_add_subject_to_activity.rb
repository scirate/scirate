class AddSubjectToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :subject_id, :integer, null: false
    add_column :activities, :subject_type, :string, null: false
  end
end
