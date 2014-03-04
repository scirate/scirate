namespace :db do
  desc "Remove duplicate categories"
  task dedup_categories: :environment do
    uids = {}

    to_delete = []

    i = 0
    Category.find_in_batches(batch_size: 10000) do |cats|
      cats.each do |cat|
        uids[cat.paper_uid] ||= {}
        if uids[cat.paper_uid][cat.position]
          # Evil duplicate
          to_delete << cat.id
        else
          uids[cat.paper_uid][cat.position] = true
        end
      end

      i += 1
      puts "Processed #{i*10000} categories | Duplicates #{to_delete.length}"
    end

    puts "Deleting #{to_delete.length} duplicates"
    Category.where(id: to_delete).delete_all
  end
end
