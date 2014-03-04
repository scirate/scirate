require 'arxivsync'

namespace :arxiv do
  desc "Update database with yesterday's papers"
  task oai_update: :environment do
    # XXX (Mispy): The way the arxiv treats datestamps
    # in OAI requests is strange. If we request from a few months ago,
    # it seems to give us updates first and then new publications.
    #
    # Hence the use of submit_date instead of update_date.
    # There is some risk here that we could end up with holes in the
    # database if a sync fails somewhere; needs further investigation.
    last_paper = Paper.order("pubdate asc").last

    if last_paper.nil?
      date = Date.today-1.days
    else
      date = last_paper.submit_date

      syncdate = nil
      if last_paper.pubdate > Date.today-1.days
        # We're in a daily sync cycle and can timestamp without estimating
        syncdate = Time.now.utc.change(hour: 1)
      end
    end


    ArxivSync.get_metadata(from: date.to_date) do |resp, papers|
      Arxiv::Import.papers(papers, syncdate: syncdate)
    end
  end
end
