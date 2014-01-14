require 'nokogiri'
require 'open-uri'

def make_feed(name, fullname, parent=nil)
  feed = Feed.find_or_create_by_name(name)
  feed.feed_type = 'arxiv'

  if name == "cs" # HACK (Mispy)
    feed.fullname = "Computer Science"
  elsif name == "physics"
    feed.fullname = "Other Physics"
  else
    feed.fullname = fullname
  end

  feed.parent = parent
  feed.updated_date ||= Date.yesterday
  feed
end

namespace :arxiv do
  desc "Scrapes category information from arxiv.org homepage into delicious Feeds"
  task scrape_categories: :environment do
    doc = Nokogiri::HTML(open("http://arxiv.org"))

    feeds = []

    doc.css('li').each do |li|
      break if li.text.include?("See our help pages")
      fullname = li.css('a')[0].text
      name = li.css('a')[1].attr('href').split('/')[2]
      parent = make_feed(name, fullname)
      feeds << parent

      li.css('a')[4..-1].each do |a|
        split = a.attr('href').split('/')
        if split[-1] == 'recent'
          name = split[2]
          fullname = a.text

          feeds << make_feed(name, fullname, parent)
        end
      end
    end

    feeds.each do |feed|
      puts unless feed.parent
      puts "#{feed.parent ? '  ' : ''}#{feed.fullname} [#{feed.name}]"
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
