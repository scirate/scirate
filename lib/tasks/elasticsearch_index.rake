namespace :es do
  desc "Reindex papers"
  task index: :environment do
    Search.full_index_papers
  end
end
