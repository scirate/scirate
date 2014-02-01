require 'nokogiri'
require 'open-uri'

def make_feed(uid, fullname, parent=nil)
  feed = Feed.find_or_create_by_uid(uid)
  feed.source = 'arxiv'

  if uid == "cs" # HACK (Mispy)
    feed.fullname = "Computer Science"
  elsif uid == "physics"
    feed.fullname = "More Physics"
  else
    feed.fullname = fullname
  end

  feed.parent_uid = parent && parent.uid
  feed
end

namespace :arxiv do
  desc "Scrapes category information from arxiv.org homepage into delicious Feeds"
  task feed_import: :environment do
    doc = Nokogiri::HTML(open("http://arxiv.org"))

    feeds = []

    doc.css('li').each do |li|
      break if li.text.include?("See our help pages")
      fullname = li.css('a')[0].text
      uid = li.css('a')[1].attr('href').split('/')[2]
      parent = make_feed(uid, fullname)
      feeds << parent

      li.css('a')[4..-1].each do |a|
        split = a.attr('href').split('/')
        if split[-1] == 'recent'
          uid = split[2]
          fullname = a.text

          feeds << make_feed(uid, fullname, parent)
        end
      end
    end

    feeds.each do |feed|
      puts unless feed.parent
      puts "#{feed.parent ? '  ' : ''}#{feed.fullname} [#{feed.uid}]"
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
