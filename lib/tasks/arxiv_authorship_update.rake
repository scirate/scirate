require 'arxivsync'

namespace :arxiv do
  desc "Update authorship for users with author_identifiers"
  task authorship_update: :environment do
    time = Time.now.utc

    User.where("author_identifier <> ''").each do |user|
      begin
        user.update_authorship!
      rescue OpenURI::HTTPError
        $stderr.puts "Invalid author_identifier for #{user.username}: #{user.author_identifier}"
      rescue Exception => e
        SciRate.notify_error(e, "Unknown error in update_authorship! for #{user.username}")
      end

      $stderr.puts "Synced authorship for #{user.username}"
    end

    System.update_all(arxiv_author_sync_dt: time)
  end
end
