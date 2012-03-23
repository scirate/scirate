class AddCommentCounterCacheToUsersAndPapers < ActiveRecord::Migration
  def change
    add_column :users,  :comments_count, :integer, default: 0
    add_column :papers, :comments_count, :integer, default: 0

    User.reset_column_information
    User.find(:all).each do |u|
      User.update_counters u.id, comments_count: u.comments.count
    end

    Paper.reset_column_information
    Paper.find(:all).each do |p|
      Paper.update_counters p.id, comments_count: p.comments.count
    end
  end
end
