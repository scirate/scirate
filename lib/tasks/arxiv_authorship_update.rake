require 'arxivsync'

namespace :arxiv do
  desc "Update authorship for users with author_identifiers"
  task authorship_update: :environment do
    time = Time.now.utc

    User.where("author_identifier <> ''").each do |user|
      begin
        $stderr.puts "Updating username #{user.username}"
        user.update_authorship!
        sleep 1
      rescue OpenURI::HTTPError
        $stderr.puts "Invalid author_identifier for #{user.username}: #{user.author_identifier}"
      rescue ActiveRecord::RecordInvalid => invalid
        $stderr.puts "Couldn't add new authorship, probably missing a paper in the database!"
        $stderr.puts invalid.record.errors
      end

      $stderr.puts "Finished syncing authorship for #{user.username}"
    end

    System.update_all(arxiv_author_sync_dt: time)
  end
end
