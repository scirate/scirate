require 'arxivsync'

namespace :arxiv do
  desc "Update database with recent papers"
  task oai_update: :environment do
    time = Time.now.utc

    last_paper = Paper.order("submit_date desc").first

    if last_paper.nil?
      fromdate = Time.now-7.days
    else
      fromdate = last_paper.pubdate
    end

    # Do this in a single transaction to avoid any database consistency issues
    bulk_papers = []
    ArxivSync.get_metadata(from: fromdate.to_date) do |resp, papers|
      bulk_papers += papers
    end

    syncdate = time.change(hour: Settings::ARXIV_UPDATE_HOUR)
    if time < syncdate
      # arxiv hasn't updated yet, we're actually syncing from yesterday
      syncdate = syncdate - 1.days
    end

    new_uids, updated_uids = Arxiv::Import.papers(bulk_papers, syncdate: syncdate)

    # Only consider it a successful update if either:
    # - we got new papers
    # - it's a weekend
    if syncdate.saturday? || syncdate.sunday? || !new_uids.empty?
      System.update_all(arxiv_sync_dt: time)
    end
  end
end
