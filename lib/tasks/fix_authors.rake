namespace :db do
  desc "Recreate authors from author_str"
  task fix_authors: :environment do
    def parse_fullnames(author_str)
      depth = 0
      no_parens = ""

      author_str.chars do |ch|
        case ch
        when '('
          depth += 1
        when ')'
          depth -= 1
        else
          no_parens << ch if depth == 0
        end
      end

      no_parens.split(/,|:|;|\sand\s/i)
        .map { |s| s.gsub(/\s+/, ' ').strip }
        .reject { |s| s.empty? }
    end

    i = 0
    Paper.find_in_batches(batch_size: 10000) do |papers|
      paper_uids = []
      author_columns = [:paper_uid, :position, :fullname, :searchterm]
      author_values = []
      
      papers.each do |paper|
        fullnames = parse_fullnames(paper.author_str)
        fullnames.each_with_index do |fullname, j|
          author_values << [
            paper.uid,
            j,
            fullname,
            Author.make_searchterm(fullname)
          ]
        end
        paper_uids << paper.uid
      end

      ActiveRecord::Base.transaction do
        Author.where(paper_uid: paper_uids).delete_all
        result = Author.import(author_columns, author_values, validate: false)
        unless result.failed_instances.empty?
          raise result.failed_instances
        end
      end

      puts "Processed #{(i+1)*10000} papers"
      i += 1
    end
  end
end
