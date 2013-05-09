namespace :db do
  desc "Update database with yesterday's papers"
  task arxiv_update: :environment do
    today = Time.now.utc.to_date

    # only update those feeds we haven't succesfully updated already
    # feeds are updated in decreasing order of subscriber count
    feeds = Feed.where("updated_date <> ? OR updated_date IS NULL", today)
                .order("subscriptions_count DESC")

    # Don't update old/obsolete feeds which have no RSS endpoint
    feeds.reject! { |feed| !Settings::CURRENT_FEEDS.include?(feed.name) }

    if feeds.size == 0
      puts "No feeds need updating"
    end

    feeds.each do |feed|
      puts "Updating #{feed.name} ... "

      print "\tFetching RSS feed ... "

      #fetch the latest RSS feed and add it to the DB
      feed_day = fetch_arxiv_rss feed

      puts "Done!"

      if feed_day.pubdate == today
        #create Paper stubs (date, identifier, feed)
        papers = parse_arxiv feed, feed_day

        print "\tUpdating papers for #{feed.name} #{feed_day.pubdate} - #{papers[:all].count - papers[:updates].count} new, #{papers[:updates].count} updates ... "

        #fetch metadata from arXiv API
        update_metadata papers

        puts "Done!"

        if papers[:all].length > papers[:updates].length
          feed.last_paper_date = today
        end
      end

      print "\tMarking #{feed.name} as updated ... "
      feed.updated_date = today
      feed.save!
      puts "Done!"

      puts ""
    end
  end
end

namespace :db do
  desc "Completely reload metadata from feed cache -- will not destroy papers"
  task :reload_metadata, [:start_date] => :environment do |t,args|

    #get FeedDay objects in ascending order of pubday
    FeedDay.where("pubdate >= ?", args.start_date).find(:all, \
                                         order: 'pubdate').each do |feed_day|
      feed = Feed.find_by_name(feed_day.feed_name)

      #create stubs
      papers = parse_arxiv feed, feed_day

      print "Reloading papers for #{feed.name} #{feed_day.pubdate} ... "
      update_metadata papers
      puts "Done!"
    end
  end
end

namespace :db do
  desc "Update a paper (passed as argument)"
  task :update_paper, [:paper_id] => :environment do |t,args|
    stubs = {}
    stub = Paper.new(identifier: args.paper_id)
    stubs[:all] = [stub]
    stubs[:updates] = [] #don't change update date
    stubs[:cross_lists] = [stub]

    update_metadata stubs
  end
end

def fetch_arxiv_rss feed
  url = URI.parse(feed.url)
  rss = Net::HTTP.get_response(url).body

  xml = REXML::Document.new(rss)

  date = xml.elements["rdf:RDF/channel/dc:date"].text.to_date

  date += 1 #arxiv mailing for day n happens on day n-1

  feed_day = FeedDay.new(pubdate: date, content: rss, feed_name: feed.name)
  feed_day.save

  return feed_day
end

def parse_arxiv feed, feed_day
  papers = []
  updates = Set.new
  cross_lists = Set.new

  xml = REXML::Document.new(feed_day.content)
  date = feed_day.pubdate

  xml.elements.each('rdf:RDF/item') do |item|
    id = item.attributes["about"][-9,9]

    # skip paper if id looks wrong (i.e. old-style identifiers)
    next unless id =~ /\d{4}\.\d{4}/

    if item.elements["title"].text =~ /\[#{feed.name}\]/
      stub = feed.papers.build(identifier: id, pubdate: date)
      papers << stub

      if item.elements["title"].text =~ /\[#{feed.name}\] UPDATED\)/
        updates << stub
      end
    end

    # Cross-listed papers are from a different feed
    if item.elements["title"].text =~ /CROSS LISTED\)/
      stub = Paper.new(identifier: id, pubdate: date)
      papers << stub
      cross_lists << stub
    end
  end

  return {all: papers, updates: updates, cross_lists: cross_lists}
end

def update_metadata papers
  manuscripts = Arxiv.query(id_list: papers[:all].map(&:identifier).join(','),
                            max_results: papers[:all].length.to_s)
  identifiers = manuscripts.map { |ms| ms.arxiv_id }

  existing = {}
  Paper.includes(:cross_lists).find_all_by_identifier(identifiers).each do |paper|
    existing[paper.identifier] = paper
  end

  feedmap = Feed.map_names

  ActiveRecord::Base.transaction do
    papers[:all].each do |stub|
      paper = existing[stub.identifier]
      # don't add new papers on updates
      next if paper.nil? && \
          (papers[:updates].include?(stub) || papers[:cross_lists].include?(stub))

      paper ||= stub
      new_paper = (paper == stub)

      ms = manuscripts[identifiers.index(stub.identifier)]

      primary_category = ms.primary_category.abbreviation
      primary_feed = feedmap[primary_category]
      next if primary_feed.nil? # Ignore these for now
      categories = ms.categories.map(&:abbreviation)

      paper.identifier = ms.arxiv_id
      paper.feed_id = primary_feed.id
      paper.title = ms.title
      paper.abstract = ms.abstract
      paper.url = "http://arxiv.org/abs/#{paper.identifier}"
      paper.pdf_url = "http://arxiv.org/pdf/#{paper.identifier}.pdf"
      paper.pubdate = paper == stub ? Time.now.utc.to_date : paper.pubdate
      paper.updated_date = Time.now.utc.to_date
      paper.authors = ms.authors.map(&:name)
      paper.save!

      categories.each do |c|
        next if c == primary_category
        feed = feedmap[c]
        next if feed.nil?
        if new_paper || !paper.cross_lists.map(&:feed_id).include?(feed.id)
          paper.cross_lists.create(feed_id: feed.id, cross_list_date: paper.pubdate)
        end
      end
    end
  end
end
