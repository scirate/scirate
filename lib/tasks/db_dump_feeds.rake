namespace :db do
  desc "Dumps feeds to seeds.rb format"
  task dump_feeds: :environment do
    output = "Feed.create(["

    feeds = []
    Feed.all.each_with_index do |feed, i|
      attrs = []
      feed.attributes.each do |key, val|
        attrs <<  "#{key}: \"#{val.to_s}\""
      end

      feeds << "{#{attrs.join(', ')}}"
    end
    output += "#{feeds.join(', ')}])"
    puts output
  end
end
