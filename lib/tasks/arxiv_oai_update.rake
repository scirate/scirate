require 'arxivsync'

namespace :arxiv do
  desc "Update database with yesterday's papers"
  task oai_update: :environment do
    last_paper = Paper.order("pubdate asc").last

    if last_paper.nil?
      date = Time.now-1.days
    else
      date = last_paper.submit_date
    end

    # Do this in a single transaction to avoid any database consistency issues
    bulk_papers = []
    ArxivSync.get_metadata(from: date.to_date) do |resp, papers|
      bulk_papers += papers
    end

    Arxiv::Import.papers(bulk_papers, syncdate: Time.now.utc.change(hour: 1))
  end
end
