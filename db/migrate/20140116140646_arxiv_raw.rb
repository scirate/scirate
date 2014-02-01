class ArxivRaw < ActiveRecord::Migration
  def change
    drop_table :papers, {}

    create_table :papers do |t|
      t.string :identifier, null: false
      t.string :submitter, null: false
      t.string :title, null: false
      t.text :abstract, null: false

      t.text :comments
      t.string :msc_class
      t.string :report_no
      t.string :journal_ref
      t.string :doi
      t.string :proxy
      t.string :license

      t.datetime :submit_date, null: false
      t.datetime :update_date, null: false
      t.string :abs_url, null: false
      t.string :pdf_url, null: false
      t.boolean :delta, default: true, null: false
      t.timestamps
    end

    add_index :papers, :identifier
    add_index :papers, :delta

    create_table :versions do |t|
      t.references :paper, null: false, index: true
      t.integer :position, null: false
      t.datetime :date, null: false
      t.datetime :size, null: false
    end

    drop_table :authorships, {}

    create_table :authors do |t|
      t.references :paper, null: false, index: true
      t.integer :position, null: false
      t.string :fullname, null: false
      t.string :searchterm, null: false
    end

    drop_table :cross_lists, {}

    add_index :authors, :searchterm

    create_table :categories do |t|
      t.references :paper, null: false, index: true
      t.integer :position, null: false
      t.string :category, null: false
    end

    add_index :categories, :category
  end
end
