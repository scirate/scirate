namespace :es do
  desc "Reindex papers using same index"
  task index: :environment do
    Search.full_index
  end
end
