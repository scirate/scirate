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

      no_parens.split(/,|:|;|\sand\s|\s?the\s/i)
        .map { |s| s.gsub(/\s+/, ' ').strip }
        .reject { |s| s.empty? }
    end

    i = 0
    loop do
      paper_uids = []
      author_columns = [:paper_uid, :position, :fullname, :searchterm]
      author_values = []

      papers = Paper.limit(10000).offset(i).pluck(:uid, :author_str)
      break if papers.empty?
      
      papers.each do |uid, author_str|
        fullnames = parse_fullnames(author_str)
        fullnames.each do |fullname, j|
          author_values << [
            uid,
            i,
            fullname,
            Author.make_searchterm(fullname)
          ]
        end
        paper_uids << uid
      end

      ActiveRecord::Base.transaction do
        Author.where(paper_uid: paper_uids).delete_all
        result = Author.import(author_columns, author_values, validate: false)
        unless result.failed_instances.empty?
          raise result.failed_instances
        end
      end

      puts (i+1)*10000
      i += 1
    end
  end
end
