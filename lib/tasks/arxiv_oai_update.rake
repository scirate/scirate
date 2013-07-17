require 'arxivsync'

namespace :arxiv do
  desc "Update database with yesterday's papers"
  task oai_update: :environment do
    last_paper = Paper.order("updated_date asc").last

    if last_paper.nil?
      date = Date.today-1.days
    else
      date = last_paper.updated_date
    end

    ArxivSync.get_metadata(from: date) do |resp, papers|
      Paper.arxiv_import(papers)
    end
  end
end
