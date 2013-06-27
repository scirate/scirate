require 'arxivsync'

namespace :db do
  desc "Update database with yesterday's papers"
  task arxiv_update: :environment do
    last_paper = Paper.order("updated_date asc").last

    ArxivSync.get_metadata(from: last_paper.updated_date) do |resp, papers|
      Paper.arxiv_import(papers)
    end
  end
end
