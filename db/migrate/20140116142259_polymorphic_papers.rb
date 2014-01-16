class PolymorphicPapers < ActiveRecord::Migration
  def change
    drop_table :comments, {}

    create_table :comments do |t|
      t.references :paper, polymorphic: true, null: false, index: true
      t.references :user, null: false, index: true

      t.integer :score, null: false, default: 0
      t.integer :cached_votes_up, null: false, default: 0
      t.integer :cached_votes_down, null: false, default: 0
      t.boolean :hidden, null: false, default: false

      t.integer :parent_id
      t.integer :ancestor_id
      
      t.timestamps
    end

    add_index :comments, :parent_id
    add_index :comments, :ancestor_id

    drop_table :scites, {}

    create_table :scites do |t|
      t.references :paper, polymorphic: true, null: false, index: true
      t.references :user, null: false, index: true
    end
    
    drop_table :feeds, {}

    create_table :feeds do |t|
      t.string :identifier, null: false
      t.string :source, null: false
      t.string :name, null: false

      t.integer :parent_id
      t.integer :position, null: false, default: 0

      t.integer :subscriptions_count, null: false, default: 0
      t.datetime :last_paper_date
    end

    add_index :feeds, :identifier
    add_index :feeds, :source
    add_index :feeds, :parent_id
  end
end
