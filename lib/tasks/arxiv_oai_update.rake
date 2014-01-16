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
    last_paper = Paper.order("submit_date asc").last

    if last_paper.nil?
      date = Date.today-1.days
    else
      date = last_paper.update_date
    end

    ArxivSync.get_metadata(from: date) do |resp, papers|
      Paper.arxiv_import(papers)
    end
  end
end
