require 'arxivsync'

namespace :arxiv do
  desc "Update authorship for users with author_identifiers"
  task authorship_update: :environment do
    threads = []

    User.where("author_identifier <> ''").each do |user|
      threads << Thread.new do
        begin
          user.update_authorship!
        rescue OpenURI::HTTPError
          $stderr.puts "Invalid author_identifier for #{user.username}: #{user.author_identifier}"
        rescue Exception => e
          SciRate.notify_error(e, "Unknown error in update_authorship! for #{user.username}")
        end

        $stderr.puts "Synced authorship for #{user.username}"
      end
    end

    threads.each { |thread| thread.join }
  end
end
