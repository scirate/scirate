namespace :db do
  desc "Add default feed (quant-ph) to all papers and feed_days with no feed"
  task add_default_feed: :environment do

    #find the default feed if it already exists
    feed = Feed.find_by_name("quant-ph")

    #if not, create it
    if feed.nil?
      feed = Feed.create(name: "quant-ph",
                         url:  "http://export.arxiv.org/rss/quant-ph",
                         feed_type: "arxiv")
    end

    #add default feed to all papers with no feed
    Paper.all.each do |p|
      if p.feed.nil?
        p.feed = feed
        p.save!
      end
    end

    FeedDay.all.each do |f|
      if f.feed_name.nil?
        f.feed_name = feed.name
        f.save!
      end
    end
  end
end
