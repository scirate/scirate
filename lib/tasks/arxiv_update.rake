namespace :db do
  desc "Update database with yesterday's papers"
  task arxiv_update: :environment do
    feed_day = fetch_arxiv_rss
    papers = parse_arxiv feed_day
    retrieve_and_add papers
  end
end

def fetch_arxiv_rss
  url = URI.parse('http://export.arxiv.org/rss/quant-ph')
  rss = Net::HTTP.get_response(url).body

  xml = REXML::Document.new(rss)
  date = xml.elements["rdf:RDF/channel/dc:date"].text.to_date

  feed_day = FeedDay.new(pubdate: date, content: rss)
  feed_day.save

  return feed_day
end

def parse_arxiv feed_day
  papers = []

  xml = REXML::Document.new(feed_day.content)

  date = xml.elements["rdf:RDF/channel/dc:date"].text.to_date

  xml.elements.each('rdf:RDF/item') do |item|
    id = item.attributes["about"][-9,9]

    if item.elements["title"].text.end_with? "[quant-ph])"
      papers << Paper.new(identifier: id, pubdate: date)
    end
  end

  return papers
end

def retrieve_and_add papers
  oai_client = OAI::Client.new 'http://export.arxiv.org/oai2'

  papers.each do |paper|
    response = oai_client.get_record(
                        identifier: "oai:arXiv.org:#{paper.identifier}",
                        metadataPrefix: "arXiv")
    item = response.record.metadata.elements["arXiv"]

    paper.title = item.elements["title"].text
    paper.abstract = item.elements["abstract"].text
    paper.url = "http://arxiv.org/abs/#{paper.identifier}"

    paper.authors = []
    item.elements.each('authors/author') do |author|
      name = "#{author.elements['forenames'].text} #{author.elements['keyname'].text}"
      paper.authors << name
    end

    paper.save
  end
end
