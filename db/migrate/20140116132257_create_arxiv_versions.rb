class CreateArxivVersions < ActiveRecord::Migration
  def change
    create_table :arxiv_versions do |t|
      t.integer :paper_id
      t.integer :position
      t.datetime :date
      t.string :size

      t.timestamps
    end
  end
end
