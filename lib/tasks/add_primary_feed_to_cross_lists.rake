namespace :db do
  desc "Add primary feed to cross-lists"
  task add_primary_feed_to_cross_lists: :environment do

    Paper.all.each do |paper|
      if !paper.cross_listed_feeds.include? paper.feed
        paper.cross_lists.create!(feed_id: paper.feed.id, \
                                  cross_list_date: paper.pubdate)
      end
    end
  end
end
