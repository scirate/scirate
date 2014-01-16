require 'nokogiri'
require 'open-uri'

def make_feed(identifier, name, parent=nil)
  feed = Feed.find_or_create_by_identifier(identifier)
  feed.source = 'arxiv'

  if name == "cs" # HACK (Mispy)
    feed.name = "Computer Science"
  elsif name == "physics"
    feed.name = "Other Physics"
  else
    feed.name = name
  end

  feed.parent = parent
  feed
end

namespace :arxiv do
  desc "Scrapes category information from arxiv.org homepage into delicious Feeds"
  task feed_import: :environment do
    doc = Nokogiri::HTML(open("http://arxiv.org"))

    feeds = []

    doc.css('li').each do |li|
      break if li.text.include?("See our help pages")
      name = li.css('a')[0].text
      identifier = li.css('a')[1].attr('href').split('/')[2]
      parent = make_feed(identifier, name)
      feeds << parent

      li.css('a')[4..-1].each do |a|
        split = a.attr('href').split('/')
        if split[-1] == 'recent'
          identifier = split[2]
          name = a.text

          feeds << make_feed(identifier, name, parent)
        end
      end
    end

    feeds.each do |feed|
      puts unless feed.parent
      puts "#{feed.parent ? '  ' : ''}#{feed.name} [#{feed.identifier}]"
    end

    puts
    print "Import this feed data? [y/N]: "
    return unless STDIN.gets.strip.downcase == 'y'

    feeds.each_with_index do |feed, i| 
      feed.position = i
      feed.save!
    end
  end
end
