class FeedsController < ApplicationController
  before_filter :find_feed, :only => [:subscribe, :unsubscribe]

  def landing
    @feeds = Feed.map_names
    render('papers/landing', :layout => nil)
  end

  def _range_query(feed_ids, backdate, date, page)
    @range_query = 
      Paper.joins(:cross_lists)
        .where("cross_lists.feed_id IN (?) AND cross_lists.cross_list_date >= ? AND cross_lists.cross_list_date <= ?", feed_ids, backdate, date)
        .order("scites_count DESC, comments_count DESC, pubdate DESC")
        .paginate(per_page: 30, page: page)
    
    paper_ids = @range_query.pluck(:id)
    Paper.includes(:feed, :authors, :cross_lists => :feed).where(id: paper_ids).index_by(&:id).slice(*paper_ids).values
  end

  # Aggregated feed
  def index
    return landing unless signed_in?

    feeds = current_user.feeds.includes(:children)
    feed_ids = feeds.map(&:id) + feeds.map(&:children).flatten.map(&:id)

    preferences = current_user.feed_preferences.where(feed_id: nil).first_or_create
    @preferences = preferences

    @date = parse_date(params) || Feed.default.last_paper_date
    @range = parse_range(params) || preferences.range
    @page = params[:page]

    if @range == :since_last
      @range = ((Time.now - preferences.previous_last_visited) / 1.day).round
      @since_last = true
    end

    @backdate = @date - @range.days
    # Remember what time range they selected
    preferences.pref_update!(@range)

    @recent_comments = Comment.includes(:paper, :user)
                              .where(:paper => { :feed_id => feed_ids })
                              .order("comments.created_at DESC")
    @scited_ids = current_user.scited_papers.pluck(:id)

    @papers = _range_query(feed_ids, @backdate, @date, @page)

    render 'feeds/show'
  end

  # Showing a feed while we aren't signed in
  def show_nouser
    @feed = Feed.find_by_name!(params[:feed])
    feed_ids = [@feed.id] + @feed.children.pluck(:id)

    @date = parse_date(params) || @feed.last_paper_date || Date.today
    @range = parse_range(params) || 0
    @page = params[:page]

    if @range == :since_last
      # If we're not signed in, there's no sense
      # in which we can do "since last"
      @range = 1
    end

    @backdate = @date - @range.days

    @recent_comments = Comment.includes(:paper, :user)
                              .where(:paper => { :feed_id => feed_ids })
                              .order("comments.created_at DESC")

    @papers = _range_query(feed_ids, @backdate, @date, @page)
  end

  def show
    return show_nouser unless signed_in?

    @feed = Feed.find_by_name(params[:feed])
    feed_ids = [@feed.id] + @feed.children.pluck(:id)
    preferences = current_user.feed_preferences.where(feed_id: @feed.id).first_or_create

    @date = parse_date(params) || @feed.last_paper_date || Date.today
    @range = parse_range(params) || preferences.range
    @page = params[:page]

    preferences.pref_update!(@range)

    if @range == :since_last
      @range = ((Time.now - preferences.previous_last_visited) / 1.day).round
      @since_last = true
    end

    @backdate = @date - @range.days

    @recent_comments = Comment.includes(:paper, :user)
                              .where(:paper => { :feed_id => feed_ids })
                              .order("comments.created_at DESC")

    @scited_ids = current_user.scited_papers.pluck(:id)

    @papers = _range_query(feed_ids, @backdate, @date, @page)
  end

  protected
    def find_feed
      @feed = Feed.find(params[:id])
    end
end
