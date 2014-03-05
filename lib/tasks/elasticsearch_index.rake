namespace :es do
  desc "Migrate search schema and reindex papers"
  task index: :environment do
    Search.migrate
  end
end
