module Search
  class << self
    attr_reader :index_name
  end

  def self.es
    @es ||= Stretcher::Server.new('http://localhost:9200')
  end

  # http://stackoverflow.com/questions/16205341/symbols-in-query-string-for-elasticsearch
  def self.sanitize(str)
    # Escape special characters
    # http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1/queryparsersyntax.html#Escaping Special Characters
    escaped_characters = Regexp.escape('\\+-&|!(){}[]^~*?:/')
    str = str.gsub(/([#{escaped_characters}])/, '\\\\\1')

    # AND, OR and NOT are used by lucene as logical operators. We need
    # to escape them
    ['AND', 'OR', 'NOT'].each do |word|
      escaped_word = word.split('').map {|char| "\\#{char}" }.join('')
      str = str.gsub(/\s*\b(#{word.upcase})\b\s*/, " #{escaped_word} ")
    end

    # Escape odd quotes
    quote_count = str.count '"'
    str = str.gsub(/(.*)"(.*)/, '\1\"\3') if quote_count % 2 == 1

    str
  end

  def self.index_name
    # This logic probably doesn't belong here
    # If it's in an initializer though it breaks code reloading
    @index_name ||= if Rails.env == 'production'
      if Settings::STAGING
        "scirate_staging"
      else
        "scirate_live"
      end
    else
      "scirate_#{Rails.env}"
    end
  end

  def self.index
    es.index(index_name)
  end

  # Defines Elasticsearch index settings
  # Changing this will require creating a new index
  def self.settings
    {
      index: {
        analysis: {
          analyzer: {
            category_path: {
              type: 'custom',
              tokenizer: 'category_path'
            }
          },
          tokenizer: {
            category_path: {
              type: 'path_hierarchy',
              delimiter: '.'
            }
          }
        }
      }
    }
  end

  # Defines our Elasticsearch type schema
  # Changing this will require creating a new index
  def self.mappings
    { 
      paper: {
        _id: { path: 'uid' },
        properties: {
          uid: { type: 'string' },
          title: { type: 'string' },
          abstract: { type: 'string' },
          authors_fullname: { type: 'string', index: 'analyzed' }, # array
          authors_searchterm: { type: 'string', index: 'analyzed' }, # array
          feed_uids: { type: 'string', search_analyzer: 'whitespace', index_analyzer: 'category_path' }, # array
          sciter_ids: { type: 'integer', index: 'not_analyzed' }, # array
          scites_count: { type: 'integer' },
          comments_count: { type: 'integer' },
          submit_date: { type: 'date' },
          update_date: { type: 'date' },
          pubdate: { type: 'date' },
        }
      }
    }
  end

  def self.full_index(index_name=nil)
    index_name ||= self.index_name
    Search::Paper.full_index(index_name)
  end

  # Fetch the true, timestamped index name behind the alias
  # e.g. scirate_test_1394158756
  def self.true_index_name
    begin
      index.request(:get, "_alias/*").keys[0]
    rescue Stretcher::RequestError::NotFound
      nil
    end
  end

  # Atomically reindexes the database
  # A new index is created, populated and then aliased to the
  # main index name. The old index is deleted. This permits
  # zero downtime mapping changes
  def self.migrate(index_suffix=nil)
    # Find the previous index, if any
    old_index = Search.true_index_name

    # Create the new index, named by time of creation (or an argument)
    # to avoid namespace conflicts with any old indexes
    index_suffix = index_suffix || Time.now.to_i.to_s
    new_index = "#{index_name}_#{index_suffix}"
    puts "Creating new index #{new_index}"
    es.index(new_index).create(settings: settings, mappings: mappings)
    es.refresh

    # Check to make sure we actually need a new index here
    unless old_index.nil?
      old_settings = es.index(old_index).get_settings[old_index]['settings']
      new_settings = es.index(new_index).get_settings[new_index]['settings']

      # uuid always varies
      old_settings['index']['uuid'] = new_settings['index']['uuid']

      old_mappings = es.index(old_index).get_mapping[old_index]['mappings']
      new_mappings = es.index(new_index).get_mapping[new_index]['mappings']

      if old_settings == new_settings && old_mappings == new_mappings
        puts "Search settings/mappings are current, no migration needed"
        es.index(new_index).delete
        return
      end
    end

    # Populate the new index with data
    Search.full_index(new_index)

    if old_index.nil?
      actions = []
    else
      actions = [
        { remove: {
          :alias => index_name,
          :index => old_index
        }}
      ]
      puts "Removing alias #{index_name} => #{old_index}"
    end

    puts "Adding alias #{index_name} => #{new_index}"
    actions << [
      { add: {
        :alias => index_name,
        :index => new_index
      }}
    ]

    es.request(:post, "_aliases", nil, actions: actions)

    unless old_index.nil?
      puts "Deleting index #{old_index}"
      es.index(old_index).delete
    end
  end

  # Force Elasticsearch to refresh the index
  # In practice this is done automatically, but the tests
  # need to know that the data is definitely available
  def self.refresh
    @es.refresh
  end

  # Drop the current search index
  # Highly destructive!! Only use in testing
  def self.drop(name=nil)
    name = name || index_name
    puts "Deleting index #{name}"
    es.index(name).delete rescue nil
  end
end

module Search::Paper
  def self.es_find(params)
    res = Search.index.type(:paper).search(params)
    puts "  Elasticsearch (#{res.raw.took}ms) #{params}"
    res
  end

  def self.es_basic(q)
    params = {
      query: {
        filtered: {
          query: {
            query_string: {
              query: q,
              default_operator: 'AND'
            }
          },
          filter: nil
        }
      }
    }
    Search::Paper.es_find(params)
  end


  def self.query_uids(q)
    search = Search::Paper::Query.new(q, "")
    search.run
    search.results.documents.map(&:uid)
  end

  # Convert a Paper object into a JSON-compatible
  # hash we can place in the search index
  def self.make_doc(paper)
    {
      '_type' => 'paper',
      'uid' => paper.uid,
      'title' => paper.title,
      'abstract' => paper.abstract,
      'authors_fullname' => paper.authors.map(&:fullname),
      'authors_searchterm' => paper.authors.map(&:searchterm),
      'feed_uids' => paper.categories.map(&:feed_uid),
      'sciter_ids' => paper.scites.map(&:user_id),
      'scites_count' => paper.scites_count,
      'comments_count' => paper.comments_count,
      'submit_date' => paper.submit_date,
      'update_date' => paper.update_date,
      'pubdate' => paper.pubdate
    }
  end

  # Add/update a single paper in the search index
  # Should be called after a paper is modified (e.g. scited)
  def self.index(paper)
    puts "Updating search index for \"#{paper.title}\""
    res = Search.index.bulk_index([make_doc(paper)])
    raise res if res.errors
  end

  # Add/update multiple papers
  # Called after an oai_update
  def self.index_by_uids(uids)
    papers = ::Paper.includes(:authors, :categories).where(uid: uids)
    
    puts "Indexing #{papers.count} papers by uid for #{Search.index_name}"

    docs = papers.map { |paper| make_doc(paper) }

    res = Search.index.bulk_index(docs)
    raise res if res.errors
  end

  def self.execute(sql, *args)
    sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [sql]+args)
    ActiveRecord::Base.connection.execute(sanitized).to_a
  end

  # Reindex entire database of papers
  # Invoked manually by rake es:index
  def self.full_index(index_name)
    puts "Indexing #{::Paper.count} papers for #{index_name}"
    first_id = nil
    slice_size = (Rails.env == 'test' ? 100 : 10000)

    start_paper = ::Paper.order(:id).first
    end_paper = ::Paper.order(:id).last

    # In case there are just no papers in the database yet
    start_id = start_paper.nil? ? 0 : start_paper.id
    end_id = end_paper.nil? ? slice_size : end_paper.id
    next_id = start_id + slice_size
    total = 0

    loop do
      break if start_id > end_id
      results = execute("SELECT papers.id, papers.uid, papers.title, papers.abstract, authors.id AS author_id, authors.fullname AS author_fullname, authors.searchterm AS author_searchterm, scites.user_id AS sciter_id, papers.scites_count, papers.comments_count, papers.submit_date, papers.update_date, papers.pubdate FROM papers LEFT JOIN authors ON authors.paper_uid=papers.uid LEFT JOIN scites ON scites.paper_uid=papers.uid WHERE papers.id >= ? AND papers.id < ? ORDER BY papers.id ASC, authors.position ASC;", start_id, next_id)
      categories = execute("SELECT papers.id, papers.uid, categories.feed_uid AS feed_uid FROM papers INNER JOIN categories ON categories.paper_uid=uid WHERE papers.id >= ? AND papers.id < ? ORDER BY categories.position", start_id, next_id)

      start_id = next_id
      next_id += slice_size
      next if results.empty?

      # Select categories separately to get correct ordering

      papers = ActiveSupport::OrderedHash.new
      
      paper = nil
      author_ids = {}
      sciter_ids = {}
      results.each do |row|
        first_id ||= row['id']
        if paper.nil? || row['uid'] != paper['uid']
          papers[paper['uid']] = paper unless paper.nil?

          author_ids = {}
          sciter_ids = {}
          paper = {
            '_type' => 'paper',
            'uid' => row['uid'],
            'title' => row['title'],
            'abstract' => row['abstract'],
            'authors_fullname' => [],
            'authors_searchterm' => [],
            'feed_uids' => [],
            'sciter_ids' => [],
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

        unless sciter_ids.has_key? row['sciter_id']
          paper['sciter_ids'] << row['sciter_id']
          sciter_ids[row['sciter_id']] = true
        end
      end
      papers[paper['uid']] = paper

      categories.each do |row|
        papers[row['uid']]['feed_uids'] << row['feed_uid']
      end

      result = Search.es.index(index_name).bulk_index(papers.values)
      raise result if result.errors

      total += papers.length
      puts total
    end
  end
end

# Represents a user search query which needs to preserve state
# for the frontend while translating itself into a json fragment
# appropriate for Elasticsearch
class Search::Paper::Query
  attr_reader :results
  attr_accessor :query, :basic, :advanced
  attr_accessor :conditions, :feed, :authors, :order, :order_sql

  # Split query on non-paren enclosed spaces
  def psplit(query)
    split = []
    depth = 0
    current = ""

    query.chars.each_with_index do |ch, i|
      if i == query.length-1
        split << current+ch
      elsif ch == ' ' && depth == 0
        split << current
        current = ""
      else
        current << ch

        if ch == '('
          depth += 1
        elsif ch == ')'
          depth -= 1
        end
      end
    end

    split
  end

  # Strip field prefix
  def tstrip(term)
    ['au:','ti:','abs:','in:','order:','date:','scited_by:'].each do |prefix|
      term = term.split(':', 2)[1] if term.start_with?(prefix)
    end

    term
  end

  # Strip parens as well
  def full_tstrip(term)
    term = tstrip(term)
    if term[0] == '(' && term[-1] == ')'
      term[1..-2]
    else
      term
    end
  end

  def parse_date(term)
    if term.match(/^\d\d\d\d$/)
      Chronic.parse(term+'-01-01')
    elsif term.match(/^\d\d\d\d-\d\d$/)
      Chronic.parse(term+'-01')
    else
      Chronic.parse(term)
    end
  end

  def parse_date_range(term)
    if term.include?('..')
      first, last = term.split('..').map { |t| parse_date(t) }
      first ||= 1000.years.ago
      last ||= Time.now
      first..last
    else
      # Allow implicit ranges like date:2012
      time = parse_date(term)
      if term.match(/^\d\d\d\d$/)
        time.beginning_of_year..time.end_of_year
      elsif term.match(/^\d\d\d\d-\d\d$/)
        time.beginning_of_month..time.end_of_month
      else
        time.beginning_of_day..time.end_of_day
      end
    end
  end

  def initialize(basic, advanced)
    @basic = basic
    @advanced = advanced

    @query = [@basic, @advanced].join(' ').strip

    @general = nil # Term to apply as OR across all text fields
    @conditions = {}
    @authors = []
    @date_range = nil
    @orders = []

    psplit(@query).each do |term|
      if term.start_with?('au:')
        if term.include?('_')
          @authors << tstrip(term)
          @conditions[:authors_searchterm] ||= []
          @conditions[:authors_searchterm] << tstrip(term)
        else
          @authors << tstrip(term)
          @conditions[:authors_fullname] ||= []
          @conditions[:authors_fullname] << tstrip(term)
        end
      elsif term.start_with?('ti:')
        @conditions[:title] ||= []
        @conditions[:title] << tstrip(term)
      elsif term.start_with?('abs:')
        @conditions[:abstract] ||= []
        @conditions[:abstract] << tstrip(term)
      elsif term.start_with?('in:')
        @conditions[:feed_uids] ||= []
        @conditions[:feed_uids] << tstrip(term)
      elsif term.start_with?('scited_by:')
        name = full_tstrip(term)
        p name

        # Prioritize username over fullname
        ids = User.where(username: name).pluck(:id)
        if ids.empty?
          ids = User.where(fullname: name).pluck(:id)
        end

        @conditions[:sciter_ids] ||= []
        @conditions[:sciter_ids] << '(' + ids.join(" OR ") + ')'
      elsif term.start_with?('order:')
        @orders << tstrip(term).to_sym
      elsif term.start_with?('date:')
        @date_range = parse_date_range(tstrip(term))
      else
        if @general
          @general += ' ' + term
        else
          @general = term
        end
      end
    end

    @sort = []

    @orders = [:recency] if @orders.empty?

    @orders.each do |order|
      case order
      when :scites then @sort << { scites_count: 'desc' }
      when :comments then @sort << { comments_count: 'desc' }
      when :recency then @sort << { pubdate: 'desc' }
      when :relevancy then nil # Standard text match sort
      end
    end

    # Everything is post-sorted by pubdate except :relevancy
    unless @sort.empty? || @orders.include?(:recency)
      @sort << { pubdate: 'desc' }
    end
  end

  def run(opts={})
    es_query = []
    es_query << Search.sanitize(@general) unless @general.nil?
    @conditions.each do |cond, vals|
      vals.each do |val|
        es_query << "#{cond}:#{val}"
      end
    end

    p es_query.join(' ')

    filter = if @date_range
      {
        range: {
          pubdate: {
            from: @date_range.first,
            to: @date_range.last
          }
        }
      }
    else
      nil
    end

    params = {
      sort: @sort,
      query: {
        filtered: {
          query: {
            query_string: {
              query: es_query.join(' '),
              default_operator: 'AND'
            }
          },
          filter: filter
        }
      }
    }.merge(opts)

    @results = Search::Paper.es_find(params)
  end
end
