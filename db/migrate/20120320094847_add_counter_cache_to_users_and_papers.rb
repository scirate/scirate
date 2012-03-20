class AddCounterCacheToUsersAndPapers < ActiveRecord::Migration
  def change
    add_column :users,  :scites_count, :integer, default: 0
    add_column :papers, :scites_count, :integer, default: 0

    User.reset_column_information
    User.find(:all).each do |u|
      User.update_counters u.id, scites_count: u.scites.count
    end

    Paper.reset_column_information
    Paper.find(:all).each do |p|
      Paper.update_counters p.id, scites_count: p.scites.count
    end
  end
end
