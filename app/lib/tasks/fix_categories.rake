namespace :db do
  desc "Remove duplicate papers"
  task dedup_papers: :environment do
    uids = {}

    to_delete = []

    i = 0
    Paper.find_in_batches(batch_size: 10000) do |papers|
      papers.each do |paper|
        if uids[paper.uid]
          # Evil duplicate
          to_delete << paper.id
        else
          uids[paper.uid] = true
        end
      end

      i += 1
      puts "Processed #{i*10000} | Duplicates #{to_delete.length}"
    end

    puts "Deleting #{to_delete.length} duplicates"
    Paper.where(id: to_delete).delete_all
  end
end
