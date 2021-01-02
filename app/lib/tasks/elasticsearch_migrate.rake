namespace :es do
  desc "Migrate search schema and reindex papers"
  task migrate: :environment do
    Search.migrate
  end
end
