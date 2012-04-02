namespace :db do
  desc "Add default feed (quant-ph) to all papers and feed_days with no feed"
  task add_feeds: :environment do

    add_feed "quant-ph", "http://export.arxiv.org/rss/quant-ph", "arxiv"
    add_feed "math-ph",  "http://export.arxiv.org/rss/math-ph",  "arxiv"
    add_feed "math.CO",  "http://export.arxiv.org/rss/math.CO",  "arxiv"
    add_feed "math.OA",  "http://export.arxiv.org/rss/math.OA",  "arxiv"
    add_feed "cs.CC",    "http://export.arxiv.org/rss/cs.CC",    "arxiv"
    add_feed "cs.CR",    "http://export.arxiv.org/rss/cs.CR",    "arxiv"
    add_feed "cs.DM",    "http://export.arxiv.org/rss/cs.DM",    "arxiv"
    add_feed "cs.DS",    "http://export.arxiv.org/rss/cs.DS",    "arxiv"
  end
end

# Creates a new feed only if it does not already exist
def add_feed name, url, type  
  if Feed.find_by_name(name).nil?
    Feed.create(name: name, url: url, feed_type: type)
  end
end
