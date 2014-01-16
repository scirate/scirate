class Woops < ActiveRecord::Migration
  def change
    drop_table :arxiv_versions
  end
end
