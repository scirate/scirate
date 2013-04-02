class PapersController < ApplicationController
  include PapersHelper

  def show
    @paper = Paper.includes(comments: :user).find_by_identifier!(params[:id])
    @categories = @paper.cross_listed_feeds.order("name").select("name").where("name != ?", @paper.feed.name)
  end

  def index_subscriptions
    # Show papers from the users's subscribed feeds
    @date ||= current_user.feed_last_paper_date
    @date ||= Feed.default.last_paper_date
    @papers = fetch_papers current_user.feed, @date, @range
    @title = "All papers in #{current_user.name}'s feed from #{describe_range(@date, @range)}"

    #this is premature optimization, but it saves one query per unscited paper
    @scited_papers = Set.new( current_user.scited_papers )
  end

  def index_all
    # Show papers from all feeds
    @date = Feed.default.last_paper_date
    @papers = Paper.paginate(page: params[:page])
    @title = "All papers from #{describe_range(@date, @range)}"
  end

  def index_feed
    # Show papers from a particular feed
    @date ||= @feed.last_paper_date
    @date ||= Feed.default.last_paper_date # If feed doesn't have papers

    @papers = fetch_papers @feed.cross_listed_papers, @date, @range
    @title = "All papers in #{@feed.name} from #{describe_range(@date, @range)}"
  end

  def index
    @date = parse_date params
    @feed = parse_feed params
    @range = parse_range params

    @recent_comments = Comment.includes(:paper, :user).limit(10).find(:all, order: "created_at DESC")

    if @feed.nil?
      return not_found if params[:feed]

      if signed_in?
        index_subscriptions
      else
        index_all
      end
    else
      index_feed
    end
  end

  def search
    manuscripts = Arxiv.search(params[:q], sortBy: 'submittedDate')
    identifiers = manuscripts.map { |ms| ms.arxiv_id }

    existing = {}
    Paper.includes(:cross_lists).find_all_by_identifier(identifiers).each do |paper|
      existing[paper.identifier] = paper
    end

    feedmap = Feed.map_names

    @papers = []
    transaction do
      manuscripts.each do |ms|
        paper = existing[ms.arxiv_id] || Paper.new

        primary_category = ms.primary_category.abbreviation
        primary_feed = feedmap[primary_category]
        next if primary_feed.nil? # Ignore these for now
        categories = ms.categories.map(&:abbreviation)

        paper.identifier = ms.arxiv_id
        paper.feed_id = primary_feed.id
        paper.title = ms.title
        paper.abstract = ms.abstract
        paper.url = "http://arxiv.org/abs/#{paper.identifier}"
        paper.pdf_url = "http://arxiv.org/pdf/#{paper.identifier}.pdf"
        paper.pubdate = ms.created_at
        paper.updated_date = ms.updated_at
        paper.authors = ms.authors.map(&:name)
        paper.save!

        categories.each do |c|
          next if c == primary_category
          feed = feedmap[c]
          next if feed.nil?
          if paper.new_record? || !paper.cross_lists.map(&:feed_id).include?(feed.id)
            paper.cross_lists.create(feed_id: feed.id, cross_list_date: paper.updated_at)
          end
        end

        @papers << paper
      end
    end
    @papers = @papers.paginate(page: params[:page])
  end

  def next
    date = parse_date params
    feed = parse_feed params

    if feed.nil? && signed_in? && current_user.has_subscriptions?
       date ||= current_user.feed_last_paper_date

      papers = current_user.feed
    else
      feed ||= Feed.default
      date ||= feed.last_paper_date

      papers = feed.cross_listed_papers
    end

    ndate = next_date(papers, date)

    if ndate.nil?
      flash[:error] = "No future papers found!"
      ndate = date
    end

    redirect_to papers_path(params.merge(date: ndate, action: nil))
  end

  def prev
    date = parse_date params
    feed = parse_feed params

    if feed.nil? && signed_in? && current_user.has_subscriptions?
      date ||= current_user.feed_last_paper_date
      papers = current_user.feed
    else
      feed ||= Feed.default
      date ||= feed.last_paper_date

      papers = feed.cross_listed_papers
    end

    pdate = prev_date(papers, date)

    if pdate.nil?
      flash[:error] = "No past papers found!"
      pdate = date
    end

    redirect_to papers_path(params.merge(date: pdate, action: nil))
  end

  private

    def parse_date params
      date = Chronic.parse(params[:date])
      date = date.to_date if !date.nil?

      return date
    end

    def parse_feed params
      feed = Feed.find_by_name(params[:feed])

      return feed
    end

    def parse_range range
      range = params[:range].to_i

      # I expect range=2 to show me two days
      range -= 1

      # negative date windows are confusing
      range = 0 if range < 0

      return range
    end

    def fetch_papers feed, date, range
      return [] if date.nil?
      collection = feed.paginate(page: params[:page])
      collection = collection.includes(:feed, :cross_lists => :feed)
      collection = collection.where("pubdate >= ? AND pubdate <= ?", date - range.days, date)
      collection = collection.order("scites_count DESC, comments_count DESC, identifier ASC")
    end

    def describe_range(date, range)
      desc = date.to_formatted_s(:rfc822)
      if range != 0
        desc = (date-range.days).to_formatted_s(:rfc822) + " to #{desc}"
      end
      desc
    end
end
