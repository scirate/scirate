namespace :db do
  desc "Update database with yesterday's papers"
  task arxiv_update: :environment do

    # if it's not yet time for the update, abort
    if Time.now.utc.hour < 2
      puts "Cannot update until 0200 UTC when arXiv is updated"
      next
    end

    # only update those feeds we haven't succesfully updated already
    # feeds are updated in decreasing order of subscriber count
    feeds = Feed.where("updated_date <> ?", Date.today).order("subscriptions_count DESC")

    if feeds.size == 0
      puts "No feeds need updating"
    end

    feeds.each do |feed|
      puts "Updating #{feed.name} ... "

      print "\tFetching RSS feed ... "

      #fetch the latest RSS feed and add it to the DB
      feed_day = fetch_arxiv_rss feed

      puts "Done!"

      if feed_day.pubdate == Date.today
        #create Paper stubs (date, identifier, feed)
        papers = parse_arxiv feed, feed_day

        print "\tUpdating papers for #{feed.name} #{feed_day.pubdate} - #{papers[:all].count - papers[:updates].count} new, #{papers[:updates].count} updates ... "

        #fetch metadata from arXiv OAI interface
        update_metadata papers

        puts "Done!"

        if papers[:all].length > papers[:updates].length
          feed.last_paper_date = Date.today
        end
      end

      print "\tMarking #{feed.name} as updated ... "
      feed.updated_date = Date.today
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
  oai_client = OAI::Client.new 'http://export.arxiv.org/oai2'

  #iterate over all the paper stubs
  papers[:all].each do |stub|

    # fetch the paper if it exists
    paper = Paper.find_by_identifier(stub.identifier)

    # don't add new papers on updates
    next if paper.nil? && \
        (papers[:updates].include?(stub) || papers[:cross_lists].include?(stub))

    # use the stub if we didn't find an existing paper
    paper ||= stub

    #fetch the record from the arXiv
    response = oai_client.get_record(
                        identifier: "oai:arXiv.org:#{paper.identifier}",
                        metadataPrefix: "arXiv")
    item = response.record.metadata.elements["arXiv"]

    paper.title = item.elements["title"].text
    paper.abstract = item.elements["abstract"].text
    paper.url = "http://arxiv.org/abs/#{paper.identifier}"
    paper.updated_date = stub.pubdate

    # fetch authors as an array
    paper.authors = []
    item.elements.each('authors/author') do |author|
      forenames = author.elements['forenames']
      keyname   = author.elements['keyname']

      if forenames.nil?
        name = keyname.text
      else
        name = "#{forenames.text} #{keyname.text}"
      end

      paper.authors << name
    end

    # save the paper
    paper.save(validate: false)

    # fetch crosslists -- the first returned element is the primary category
    categories = item.elements['categories'].text.split.drop(1)

    # create crosslists
    categories.each do |c|
      feed = Feed.find_by_name(c)
      date = stub.pubdate || paper.pubdate

      # don't recreate cross-list if it already exists
      if !paper.cross_listed_feeds.include? feed
        paper.cross_lists.create!(feed_id: feed.id, \
                                  cross_list_date: date)
      end
    end
  end
end
