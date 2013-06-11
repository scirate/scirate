require 'arxivsync'

namespace :db do
  desc "Bulk import of scraped arxiv data"
  task :arxiv_import, [:savedir] => :environment do |t,args|
    archive = ArxivSync::XMLArchive.new(args.savedir)
    archive.read_metadata do |papers|
      Paper.arxivsync_import(papers)
    end
  end
end
