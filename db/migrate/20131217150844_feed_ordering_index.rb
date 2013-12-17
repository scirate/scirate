class FeedOrderingIndex < ActiveRecord::Migration
  def change
    add_index :papers, :scites_count, order: { scites_count: :desc }
    add_index :papers, :comments_count, order: { comments_count: :desc }
    add_index :papers, [:scites_count, :comments_count], order: { scites_count: :desc, comments_count: :desc }
  end
end
