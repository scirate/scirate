class UpdateActsAsVotable < ActiveRecord::Migration
  def change
    add_column :votes, :vote_weight, :integer
  end
end
