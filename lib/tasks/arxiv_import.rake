namespace :db do
  desc "Bulk import of scraped arxiv date"
  task :arxiv_import, [:savedir] => :environment do |t,args|
    metadatas = []
    total = 0
    Arxiv.read_archive(args.savedir) do |metadata|
      metadatas << metadata
      if metadatas.length >= 100
        Paper.import_metadata(metadatas)
        metadatas = []
        total += 100
        puts "Imported #{total} papers..."
      end
    end
  end
end
