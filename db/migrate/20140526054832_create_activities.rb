class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, null: false
      t.string :type, null: false
      t.timestamps
    end
  end
end
