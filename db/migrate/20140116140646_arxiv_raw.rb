class ArxivRaw < ActiveRecord::Migration
  def change
    drop_table :papers, {}

    create_table :arxiv_papers do |t|
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

    add_index :arxiv_papers, :identifier
    add_index :arxiv_papers, :delta

    drop_table :arxiv_versions, {}

    create_table :arxiv_versions do |t|
      t.references :arxiv_paper, null: false, index: true
      t.integer :position, null: false
      t.datetime :date, null: false
      t.datetime :size, null: false
    end

    drop_table :authorships, {}

    create_table :arxiv_authors do |t|
      t.references :arxiv_paper, null: false, index: true
      t.integer :position, null: false
      t.string :fullname, null: false
      t.string :searchterm, null: false
    end

    drop_table :cross_lists, {}

    add_index :arxiv_authors, :searchterm

    create_table :arxiv_categories do |t|
      t.references :arxiv_paper, null: false, index: true
      t.integer :position, null: false
      t.string :category, null: false
    end

    add_index :arxiv_categories, :category
  end
end
