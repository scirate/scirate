namespace :es do
  desc "Reindex papers"
  task index: :environment do
    Search.index_papers
  end
end
