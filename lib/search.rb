module Search
  def self.es
    if @es.nil?
      # This logic probably doesn't belong here
      # If it's in an initializer though it breaks code reloading
      @index = if Rails.env == 'production'
        if Settings::STAGING
          "scirate_staging"
        else
          "scirate_live"
        end
      else
        "scirate_#{Rails.env}"
      end

      @es = Stretcher::Server.new('http://localhost:9200')
    else
      @es
    end
  end

  def self.find_papers(params)
    res = es.index(@index).type(:paper).search(params)
    puts "  Elasticsearch (#{res.raw.took}ms) #{params}"
    res
  end

  # Convert a Paper object into a JSON-compatible
  # hash we can place in the search index
  def self.paper_to_doc(paper)
    {
      '_type' => 'paper',
      '_id' => paper.uid,
      'title' => paper.title,
      'abstract' => paper.abstract,
      'authors_fullname' => paper.authors.map(&:fullname),
      'authors_searchterm' => paper.authors.map(&:searchterm),
      'feed_uids' => paper.categories.map(&:feed_uid),
      'scites_count' => paper.scites_count,
      'comments_count' => paper.comments_count,
      'submit_date' => paper.submit_date,
      'update_date' => paper.update_date,
      'pubdate' => paper.pubdate
    }
  end

  # Add/update a single paper in the search index
  # Should be called after a paper is modified (e.g. scited)
  def self.index_paper(paper)
    es.index(@index).bulk_index([paper_to_doc(paper)])
  end

  # Add/update multiple papers
  # Called after an oai_update
  def self.index_papers_by_uids(uids)
    papers = Paper.includes(:authors, :categories).where(uid: uids)
    
    puts "Search indexing #{papers.count} papers..."

    docs = papers.map { |paper| paper_to_doc(paper) }

    es.index(@index).bulk_index(docs)
  end

  # Reindex entire database of papers
  # Invoked manually by rake es:index
  def self.full_index_papers
    first_id = nil
    prev_id = 0
    loop do
      command = ["SELECT papers.id, papers.uid, papers.title, papers.abstract, authors.id AS author_id, authors.fullname AS author_fullname, authors.searchterm AS author_searchterm, categories.id AS category_id, categories.feed_uid, papers.scites_count, papers.comments_count, papers.submit_date, papers.update_date, papers.pubdate FROM papers INNER JOIN authors ON authors.paper_uid=uid INNER JOIN categories ON categories.paper_uid=uid WHERE papers.id > ? ORDER BY papers.id ASC LIMIT 10000;", prev_id]
      sql = ActiveRecord::Base.send(:sanitize_sql_array, command)
      results = ActiveRecord::Base.connection.execute(sql).to_a
      break if results.empty?

      paper = nil
      papers = []
      author_ids = {}
      category_ids = {}
      results.each do |row|
        first_id ||= row['id']
        if paper.nil? || row['uid'] != paper['_id']
          papers << paper unless paper.nil?

          category_ids = {}
          author_ids = {}
          prev_id = row['id']
          paper = {
            '_type' => 'paper',
            '_id' => row['uid'],
            'title' => row['title'],
            'abstract' => row['abstract'],
            'authors_fullname' => [],
            'authors_searchterm' => [],
            'feed_uids' => [],
            'scites_count' => row['scites_count'].to_i,
            'comments_count' => row['comments_count'].to_i,
            'submit_date' => Time.parse(row['submit_date'] + " UTC"),
            'update_date' => Time.parse(row['update_date'] + " UTC"),
            'pubdate' => Time.parse(row['pubdate'] + " UTC")
          }
        end

        unless author_ids.has_key? row['author_id']
          paper['authors_fullname'] << row['author_fullname']
          paper['authors_searchterm'] << row['author_searchterm']
          author_ids[row['author_id']] = true
        end

        unless category_ids.has_key? row['category_id']
          paper['feed_uids'] << row['feed_uid']
          category_ids[row['category_id']] = true
        end
      end

      result = es.index(@index).bulk_index(papers)
      raise result if result.errors

      p prev_id.to_i-first_id.to_i
    end
  end

  # Clear out the entire search database
  # Used for testing
  def self.clear_index
    es.index(@index).delete rescue nil
  end
end
