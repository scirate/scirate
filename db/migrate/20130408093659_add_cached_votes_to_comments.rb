class AddCachedVotesToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :cached_votes_up, :integer, :default => 0
    add_column :comments, :cached_votes_down, :integer, :default => 0
    add_index  :comments, :cached_votes_up
    add_index  :comments, :cached_votes_down
  end

  def self.down
    remove_column :comments, :cached_votes_up
    remove_column :comments, :cached_votes_down
  end
end
