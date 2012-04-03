namespace :db do
  desc "Rebuild counter caches for users and papers"
  task rebuild_counter_caches: :environment do

    User.reset_column_information
    User.find(:all).each do |u|
      User.reset_counters u.id, :scites
      User.reset_counters u.id, :comments
    end

    Paper.reset_column_information
    Paper.find(:all).each do |p|
      Paper.reset_counters p.id, :scites
      Paper.reset_counters p.id, :comments
    end
  end
end
