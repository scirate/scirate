namespace :db do
  desc "Mark all feeds to be updated by setting last updated date to yesterday"
  task mark_feeds_for_update: :environment do

    Feed.all.each do |f|
      f.updated_date = Date.yesterday
      f.save
    end
  end
end
