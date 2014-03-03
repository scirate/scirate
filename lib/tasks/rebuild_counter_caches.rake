namespace :db do
  desc "Rebuild counter caches for users and papers"
  task rebuild_counter_caches: :environment do
    Scite.includes(:user, :paper).each do |scite|
      User.reset_counters scite.user.id, :scites
      Paper.reset_counters scite.paper.id, :scites
    end

    Comment.includes(:user, :paper).each do |comment|
      User.reset_counters comment.user.id, :comments
      Paper.reset_counters comment.paper.id, :comments
    end
  end
end
