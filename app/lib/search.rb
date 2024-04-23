require 'data_helpers'
require 'elasticsearch'

module Search
  class << self
    attr_reader :index_name
  end

  def self.es
    host = Settings::ELASTIC_SEARCH_HOST
    @es ||= Elasticsearch::Client.new url: "http://#{host}:9200", log: false
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

  # Let the user apply boolean operators and brackets, but escape
  # everything else (wildcards in particular are dangerous)
  def self.partial_sanitize(str)
    # Escape special characters
    # http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1/queryparsersyntax.html#Escaping Special Characters
    escaped_characters = Regexp.escape('\\+-&|!{}[]^~*?:/')
    str = str.gsub(/([#{escaped_characters}])/, '\\\\\1')

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
    elsif Rails.env == 'profile'
      "scirate_development"
    else
      "scirate_#{Rails.env}"
    end
  end

  def self.index
    es.indices.get index: index_name
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
        properties: {
          uid: { type: 'keyword' },
          title: { type: 'text' },
          abstract: { type: 'text' },
          authors_fullname: { type: 'text' }, # array
          authors_searchterm: { type: 'keyword'}, # array
          feed_uids: { type: 'text', analyzer: 'category_path', search_analyzer: 'whitespace' }, # array
          sciter_ids: { type: 'integer' }, # array
          scites_count: { type: 'integer' },
          comments_count: { type: 'integer' },
          submit_date: { type: 'date' },
          update_date: { type: 'date' },
          pubdate: { type: 'date' },
          pdf_url: { type: 'text', index: false }
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
      al = es.indices.get_alias index: self.index_name
      al.keys[0]
    rescue => e
      nil
    end
  end


  def self.create_index (name:, settings: nil, mappings: nil)
    settings ||= Search.settings
    mappings ||= Search.mappings
    es.indices.create index: name, body: { settings: settings, mappings: mappings }
  end

  def self.add_alias (index:, alias_name:)
    es.indices.update_aliases body: { actions: [ { add: { index: index, alias: alias_name, is_write_index: true } } ] }
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

    self.create_index name: new_index
    es.indices.refresh index: new_index

    # Check to make sure we actually need a new index here
    unless old_index.nil?
      old_settings = (es.indices.get_settings index: old_index)[old_index]['settings']
      new_settings = (es.indices.get_settings index: new_index)[new_index]['settings']

      # uuid and creation date always vary
      old_settings['index']['uuid'] = new_settings['index']['uuid']
      old_settings['index']['creation_date'] = new_settings['index']['creation_date']
      # As does the name, naturally
      old_settings['index']['provided_name'] = new_settings['index']['provided_name']

      old_mappings = (es.indices.get_mapping index: old_index)[old_index]['mappings']
      new_mappings = (es.indices.get_mapping index: new_index)[new_index]['mappings']

      if old_settings == new_settings && old_mappings == new_mappings
        puts "Search settings/mappings are current, no migration needed"
        es.indices.delete index: new_index
        return
      end
    end

    # Populate the new index with data
    full_index(new_index)

    if old_index.nil?
      actions = []
    else
      puts "Removing alias #{index_name} => #{old_index}"
      es.indices.delete_alias index: old_index, name: index_name rescue nil
    end

    puts "Adding alias #{index_name} => #{new_index}"
    es.indices.update_aliases body: { actions: [ {add: {index: new_index, alias: index_name, is_write_index: true }} ] }

    unless old_index.nil?
      puts "Deleting index #{old_index}"
      es.indices.delete index: old_index
    end
  end

  # Force Elasticsearch to refresh the index
  # In practice this is done automatically, but the tests
  # need to know that the data is definitely available
  def self.refresh
    es.indices.refresh index: self.index_name
  end

  # Drop the current search index
  # Highly destructive!! Only use in testing
  def self.drop(name=nil)
    name = name || Search.true_index_name
    puts "Deleting index #{name}"
    es.indices.delete index: name rescue nil
  end
end

module Search::Paper
  def self.es_find(params)
    res = Search.es.search index: Search.index_name, body: params
    puts "  Elasticsearch (#{res['took']}ms) "
    # puts "Elasticsearch results: #{params}"
    res
  end

  def self.es_basic(q)
    params = {
      query: {
        query_string: {
          query: q,
          default_operator: 'AND'
        }
      }
    }
    Search::Paper.es_find(params)
  end


  def self.query_uids(q)
    search = Search::Paper::Query.new(q, "")
    search.run
    res = search.results["hits"]["hits"]
    res.map { |p| p["_source"]["uid"] }
  end

  # Convert a Paper object into a JSON-compatible
  # hash we can place in the search index
  def self.make_doc(paper)
    {
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
      'pubdate' => paper.pubdate,
      'pdf_url' => paper.pdf_url
    }
  end

  # Add/update papers in the search index
  # Should be called after papers are modified (e.g. scited)
  def self.index(*papers)
    puts "Updating search index for #{papers.map(&:title)}"

    docs = []
    papers.each do |paper|
      docs.append( {"index": { "_index": Search.index_name, "_id": paper.uid } })
      docs.append( make_doc(paper) )
    end

    res = Search.es.bulk index: Search.index_name, body: docs

    raise StandardError.new (res) if res["errors"]
  end


  # Add/update multiple papers
  # Called after an oai_update
  def self.index_by_uids(uids)
    papers = ::Paper.includes(:authors, :categories).where(uid: uids)

    puts "Indexing #{papers.count} papers by uid for #{Search.index_name}"

    Search::Paper.index(*papers)
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
      results = execute("SELECT papers.id, papers.uid, papers.title, papers.abstract, authors.id AS author_id, authors.fullname AS author_fullname, authors.searchterm AS author_searchterm, scites.user_id AS sciter_id, papers.scites_count, papers.comments_count, papers.submit_date, papers.update_date, papers.pubdate, papers.pdf_url FROM papers LEFT JOIN authors ON authors.paper_uid=papers.uid LEFT JOIN scites ON scites.paper_uid=papers.uid WHERE papers.id >= ? AND papers.id < ? ORDER BY papers.id ASC, authors.position ASC;", start_id, next_id)
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
            'uid' => row['uid'],
            'title' => row['title'],
            'abstract' => row['abstract'],
            'authors_fullname' => [],
            'authors_searchterm' => [],
            'feed_uids' => [],
            'sciter_ids' => [],
            'scites_count' => row['scites_count'].to_i,
            'comments_count' => row['comments_count'].to_i,
            'submit_date' => row['submit_date'],
            'update_date' => row['update_date'],
            'pubdate' => row['pubdate'],
            'pdf_url' => row['pdf_url']
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
        p = papers[row['uid']]
        p['feed_uids'] << row['feed_uid']
      end

      docs = []
      papers.values.each do |paper|
        docs.append( {"index": { "_index": index_name, "_id": paper["uid"] } })
        docs.append( paper )
      end

      result = Search.es.bulk index: index_name, body: docs
      raise result if result["errors"]

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

    Search.partial_sanitize(term)
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
    term = term.gsub('\\', '')
    if term.include?('..')
      first, last = term.split('..').map { |t| parse_date(t) }
    else
      # Allow implicit ranges like date:2012
      time = parse_date(term)
      if term.match(/^\d\d\d\d$/)
        first = time.beginning_of_year
        last = time.end_of_year
      elsif term.match(/^\d\d\d\d-\d\d$/)
        first = time.beginning_of_month
        last = time.end_of_month
      else
        first = time.beginning_of_day
        last = time.end_of_day
      end
    end
    first ||= 1000.years.ago
    last ||= Time.now
    first..last
  end

  def initialize(basic, advanced)
    @basic = basic
    @advanced = advanced

    @query = [@basic, @advanced].join(' ').strip

    @general = nil # Term to apply as OR across all text fields
    @date_range = nil
    @orders = []
    @es_query = []

    psplit(@query).each do |term|
      if term.start_with?('au:')
        if term.include?('_')
          @es_query << "authors_searchterm:" + tstrip(term)
        else
          @es_query << "authors_fullname:" + tstrip(term)
        end
      elsif term.start_with?('ti:')
        @es_query << "title:" + tstrip(term)
      elsif term.start_with?('abs:')
        @es_query << "abstract:" + tstrip(term)
      elsif term.start_with?('in:')
        @es_query << "feed_uids:" + tstrip(term)
      elsif term.start_with?('scited_by:')
        name = full_tstrip(term)

        # Prioritize username over fullname
        ids = User.where(username: name).pluck(:id)
        if ids.empty?
          ids = User.where(fullname: name).pluck(:id)
        end

        if !ids.empty?
          @es_query << 'sciter_ids:' + '(' + ids.join(" OR ") + ')'
        end
      elsif term.start_with?('order:')
        @orders << tstrip(term).to_sym
      elsif term.start_with?('date:')
        @date_range = parse_date_range(tstrip(term))
        @es_query << 'pubdate:[' + @date_range.first.to_s[0..9] + ' TO ' + @date_range.last.to_s[0..9] + ']'
      else
        @es_query << Search.partial_sanitize(term)
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
    query = {
        query_string: {
          query: @es_query.join(' '),
          default_operator: 'AND'
        }
    }

    params = {
      sort: @sort,
      query: query
    }.merge(opts)

    @results = Search::Paper.es_find(params)
  end
end
