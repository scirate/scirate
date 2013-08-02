class FeedsController < ApplicationController
  before_filter :find_feed, :only => [:subscribe, :unsubscribe]

  def landing
    @feeds = Feed.map_names
    render('papers/landing', :layout => nil)
  end

  # Aggregated feed
  def index
    return landing unless signed_in?

    feeds = current_user.feeds.includes(:children)
    feed_ids = feeds.map(&:id) + feeds.map(&:children).flatten.map(&:id)

    @date = parse_date(params) || Feed.default.last_paper_date
    @range = parse_range(params)
    @page = params[:page]

    @recent_comments = Comment.joins(:paper)
                              .where(:paper => { :feed_id => feed_ids })
                              .order("created_at DESC")
    @scited_papers = Set.new(current_user.scited_papers)

    @papers = Paper.where(cross_lists: { feed_id: feed_ids })
    @papers = Paper.range_query(@papers, @date, @range, @page)
    render 'feeds/show'
  end

  def show
    @feed = Feed.find_by_name(params[:feed])
    feed_ids = [@feed.id] + @feed.children.pluck(:id)

    @date = parse_date(params) || @feed.last_paper_date || Date.today
    @range = parse_range(params)
    @page = params[:page]

    @recent_comments = Comment.joins(:paper)
                              .where(:paper => { :feed_id => feed_ids })
                              .order("created_at DESC")
    @scited_papers = Set.new(current_user.scited_papers) if signed_in?

    @papers = Paper.where(cross_lists: { feed_id: feed_ids })
    @papers = Paper.range_query(@papers, @date, @range, @page)
  end

  def subscribe
    @feed.subscriptions.find_or_create_by(user_id: current_user.id)
    render :partial => 'subscribe', :locals => { :feed => @feed }
  end

  def unsubscribe
    @feed.subscriptions.where(user_id: current_user.id).destroy_all
    render :partial => 'subscribe', :locals => { :feed => @feed }
  end

  protected
    def find_feed
      @feed = Feed.find(params[:id])
    end
end
