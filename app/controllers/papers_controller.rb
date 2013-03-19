class PapersController < ApplicationController
  include PapersHelper

  def show
    @paper = Paper.includes(comments: :user).find_by_identifier!(params[:id])
    @categories = @paper.cross_listed_feeds.order("name").select("name").where("name != ?", @paper.feed.name)
  end

  def index
    @date = parse_date params
    @feed = parse_feed params
    @range = parse_range params

    if @feed.nil? && signed_in? && current_user.has_subscriptions?
      @date ||= current_user.feed_last_paper_date
      @papers = fetch_papers current_user.feed, @date, @range

      @feed_name = "#{current_user.name}'s feed"
      @feed = nil
    elsif @feed.nil?
      @date = Feed.default.last_paper_date
      @papers = Paper.paginate(page: params[:page])
      @feed_name = "foo"
    else
      @date ||= @feed.last_paper_date

      @papers = fetch_papers @feed.cross_listed_papers, @date, @range
      @feed_name = @feed.name
    end

    @recent_comments = Comment.includes(:paper, :user).limit(10).find(:all, order: "created_at DESC")

    #this is premature optimization, but it saves one query per unscited paper
    if signed_in?
      @scited_papers = Set.new( current_user.scited_papers )
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
      collection = feed.paginate(page: params[:page])
      collection = collection.includes(:feed)
      collection = collection.where("pubdate >= ? AND pubdate <= ?", date - range.days, date)
      collection = collection.order("scites_count DESC, comments_count DESC, identifier ASC")
    end
end
