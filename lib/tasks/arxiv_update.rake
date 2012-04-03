namespace :db do
  desc "Update database with yesterday's papers"
  task arxiv_update: :environment do

    Feed.all.each do |feed|
      puts "Updating #{feed.name} ... "

      print "Fetching RSS feed ... "

      #fetch the latest RSS feed and add it to the DB
      feed_day = fetch_arxiv_rss feed

      puts "Done!"

      if feed_day.pubdate == Date.today
        #create Paper stubs (date, identifier, feed)
        papers = parse_arxiv feed, feed_day

        puts "Updating papers for #{feed.name} #{feed_day.pubdate} - #{papers[:all].count - papers[:updates].count} new, #{papers[:updates].count} updates"

        print "Fetching metadata ... "

        #fetch metadata from arXiv OAI interface
        update_metadata papers

        puts "Done!"
      end
    end
  end
end

namespace :db do
  desc "Completely rebuild metadata database from cache of feed"
  task rebuild_metadata: :environment do

    #ensure we have the latest RSS feeds
    Feed.all.each do |feed|
      fetch_arxiv_rss feed
    end

    puts "Deleting papers from DB"
    Paper.delete_all

    #get FeedDay objects in ascending order of pubday
    FeedDay.find(:all, order: 'pubdate').each do |feed_day|
      feed = Feed.find_by_name(feed_day.feed_name)

      #create stubs
      papers = parse_arxiv feed, feed_day

      print "Reloading papers for #{feed.name} #{feed_day.pubdate} ... "
      update_metadata papers
      puts "Done!"
    end
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

  xml = REXML::Document.new(feed_day.content)
  date = feed_day.pubdate

  xml.elements.each('rdf:RDF/item') do |item|
    id = item.attributes["about"][-9,9]

    if item.elements["title"].text =~ /\[#{feed.name}\]/
      stub = feed.papers.build(identifier: id, pubdate: date)
      papers << stub

      if item.elements["title"].text =~ /\[#{feed.name}\] UPDATED\)/
        updates << stub
      end
    end
  end

  return {all: papers, updates: updates}
end

def update_metadata papers
  oai_client = OAI::Client.new 'http://export.arxiv.org/oai2'

  #iterate over all the paper stubs
  papers[:all].each do |stub|

    # fetch the paper if it exists
    paper = Paper.find_by_identifier(stub.identifier)

    # don't add new papers on updates
    next if paper.nil? && papers[:updates].include?(stub)

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

    paper.authors = []
    item.elements.each('authors/author') do |author|
      name = "#{author.elements['forenames'].text} #{author.elements['keyname'].text}"
      paper.authors << name
    end

    paper.save(validate: false)
  end
end
