require 'arxivsync'

namespace :arxiv do
  desc "Bulk import of scraped arxiv data"
  task :import, [:savedir] => :environment do |t,args|
    archive = ArxivSync::XMLArchive.new(args.savedir)
    archive.read_metadata do |papers|
      Paper.arxiv_import(papers, validate: false)
    end
  end
end
