class Metadata
  attr_accessor :id, :created, :updated, :title, :abstract, :categories, :authors
  attr_accessor :primary_category, :crosslists
end

class OxSax < ::Ox::Sax
  attr_accessor :models

  def initialize
    @models = []
  end

  def start_element(name)
    @el = name
    case @el
    when :author
      @authors.push("") # Open an authors tag
    end
  end

  def text(str)
    case @el
    when :id
      @model = Metadata.new
      @model.id = str
      @authors = []
    when :created
      @model.created = str
    when :updated
      @model.updated = str
    when :title
      @model.title = str
    when :abstract
      @model.abstract = str
    when :categories
      @model.primary_category = str.split[0]
      @model.crosslists = str.split.drop(1)
    when :keyname
      @authors[-1] += str
    when :forenames
      @authors[-1] += str
    end
  end

  def end_element(name)
    case name
    when :metadata # End of a paper entry
      #@paper.updated_date ||= @paper.pubdate # If no separate updated date
      #@paper.feed_id = Feed.get_or_create(@primary_category).id
      @model.authors = @authors

      @models.push(@model)
    end
    @el = nil
  end

end

namespace :db do
  desc "Bulk import of scraped arxiv data"
  task :arxiv_import, [:savedir] => :environment do |t,args|
    savedir = "/home/mispy/arxiv"

    Dir.glob(File.join(savedir, '*')).each do |path|
      handler = OxSax.new()
      Ox.sax_parse(handler, File.open(path))
      models = handler.models

      ### First pass: Create any new feeds.

      existing_feeds = Feed.all.map(&:name)

      # Feeds to add as columns + values
      feed_columns = [:name, :url, :feed_type]
      feed_values = []

      models.each do |model|
        ([model.primary_category]+model.crosslists).each do |category|
          unless existing_feeds.include?(category)
            feed_values.push([
              category,
              "http://export.arxiv.org/rss/#{category}",
              "arxiv"
            ])
            existing_feeds.push(category)
          end
        end
      end

      puts "Importing #{feed_values.length} new feeds..." unless feed_values.empty?
      Feed.import(feed_columns, feed_values, validate: false)

      feeds_by_name = Feed.map_names

      ### Second pass: Add any new papers.
      
      identifiers = models.map(&:id)
      existing_papers = Paper.find_all_by_identifier(identifiers).map(&:identifier)

      # Papers to add as columns+values
      paper_columns = [:identifier, :feed_id, :url, :pdf_url, :title, :abstract, :pubdate, :updated_date, :authors]
      paper_values = []

      models.each do |model|
        next if existing_papers.include?(model.id)

        paper = [model.id,
          feeds_by_name[model.primary_category].id,
          "http://arxiv.org/abs/#{model.id}",
          "http://arxiv.org/pdf/#{model.id}.pdf",
          model.title,
          model.abstract,
          model.created,
          model.updated || model.created,
          model.authors
        ]
        paper_values.push(paper)
      end

      puts "Importing #{paper_values.length} new papers..." unless paper_values.empty?
      Paper.import(paper_columns, paper_values, validate: false)

      ### Finally: crosslists!
      
      crosslist_columns = [:paper_id, :feed_id, :cross_list_date]
      crosslist_values = []
      
      papers_by_ident = {}
      new_papers = Paper.find_all_by_identifier(paper_values.map { |p| p[0] })
      new_papers.each do |paper|
        papers_by_ident[paper.identifier] = paper
      end

      models.each do |model|
        paper = papers_by_ident[model.id]
        next if paper.nil?
        model.crosslists.each do |category|
          crosslist_values.push([
            papers_by_ident[model.id].id,
            feeds_by_name[category].id,
            model.created
          ])
        end
      end

      #puts "Importing #{crosslist_values.length} crosslists..." unless crosslist_values.empty?
      CrossList.import(crosslist_columns, crosslist_values, validate: false)
    end
  end
end
