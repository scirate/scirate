require 'arxivsync'

namespace :arxiv do
  desc "Update authorship for users with author_identifiers"
  task authorship_update: :environment do
    User.where('author_identifier IS NOT NULL').each do |user|
      user.update_authorship!
    end
  end
end
