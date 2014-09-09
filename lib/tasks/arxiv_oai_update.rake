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


    syncdate = Time.now.utc.change(hour: Settings::ARXIV_UPDATE_HOUR)
    Arxiv::Import.papers(bulk_papers, syncdate: syncdate)
    System.update_all(arxiv_sync_dt: syncdate)
  end
end
