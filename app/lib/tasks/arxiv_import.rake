require 'arxivsync'
require 'arxiv_import'

namespace :arxiv do
  desc "Bulk import of scraped arxiv data"
  task :import, [:savedir] => :environment do |t,args|
    archive = ArxivSync::XMLArchive.new(args.savedir)
    archive.read_metadata do |papers|
      Arxiv::Import.papers(papers, validate: false)
    end
  end
end
