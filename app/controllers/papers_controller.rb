class PapersController < ApplicationController
  include PapersHelper

  def show
    @paper = Paper.find_by_identifier!(params[:id])

    # Less naive statistical comment sorting as per
    # http://www.evanmiller.org/how-not-to-sort-by-average-rating.html
    @comments = Comment.find_by_sql([
      "SELECT *, COALESCE(((cached_votes_up + 1.9208) / NULLIF(cached_votes_up + cached_votes_down, 0) - 1.96 * SQRT((cached_votes_up * cached_votes_down) / NULLIF(cached_votes_up + cached_votes_down, 0) + 0.9604) / NULLIF(cached_votes_up + cached_votes_down, 0)) / (1 + 3.8416 / NULLIF(cached_votes_up + cached_votes_down, 0)), 0) AS ci_lower_bound FROM comments WHERE paper_id = ? AND (hidden = FALSE OR user_id = ?) ORDER BY ci_lower_bound DESC;",
      @paper.id,
      current_user ? current_user.id : nil
    ])

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

    @recent_comments = Comment.includes(:paper, :user).limit(10).where(hidden: false).order("created_at DESC")

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
    @papers = Paper.basic_search(params[:q]).paginate(page: params[:page])
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
