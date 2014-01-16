class FeedsController < ApplicationController
  def landing
    @feeds = Feed.map_uids
    render('papers/landing', :layout => nil)
  end

  def _recent_comments(feed_uids)
    @recent_comments = Comment.joins(:paper, paper: :categories)
                              .where(paper: { categories: { feed_uid: feed_uids } })
                              .order("comments.created_at DESC")
  end

  def _range_query(feed_uids, backdate, date, page)
    @range_query =
      Paper.joins(:categories)
        .where("categories.feed_uid IN (?) AND papers.submit_date >= ? AND papers.submit_date <= ?", feed_uids, backdate, date)
        .order("scites_count DESC, comments_count DESC, submit_date DESC")
        .paginate(per_page: 30, page: page)

    paper_ids = @range_query.pluck(:id)
    Paper.includes(:authors, :feeds).where(id: paper_ids).index_by(&:id).slice(*paper_ids).values
  end

  # Aggregated feed
  def index
    return landing unless signed_in?

    feeds = current_user.feeds.includes(:children)
    feed_uids = feeds.map(&:uid) + feeds.map(&:children).flatten.map(&:uid)

    preferences = current_user.feed_preferences.where(feed_id: nil).first_or_create
    @preferences = preferences

    @date = parse_date(params) || Date.today
    @range = parse_range(params) || preferences.range
    @page = params[:page]

    if @range == :since_last
      @range = ((Time.now - preferences.previous_last_visited) / 1.day).round
      @since_last = true
    end

    @backdate = @date - @range.days
    # Remember what time range they selected
    preferences.pref_update!(@range)

    @recent_comments = _recent_comments(feed_uids)

    @scited_ids = current_user.scited_papers.pluck(:id)

    @papers = _range_query(feed_uids, @backdate, @date, @page)

    render 'feeds/show'
  end

  # Showing a feed while we aren't signed in
  def show_nouser
    @feed = Feed.find_by_uid!(params[:feed])
    feed_uids = [@feed.uid] + @feed.children.pluck(:uid)

    @date = parse_date(params) || @feed.last_paper_date.to_date || Date.today
    @range = parse_range(params) || 0
    @page = params[:page]

    if @range == :since_last
      # If we're not signed in, there's no sense
      # in which we can do "since last"
      @range = 1
    end

    @backdate = @date - @range.days

    @recent_comments = _recent_comments(feed_uids)

    @papers = _range_query(feed_uids, @backdate, @date, @page)
  end

  def show
    return show_nouser unless signed_in?

    @feed = Feed.find_by_uid!(params[:feed])
    feed_uids = [@feed.uid] + @feed.children.pluck(:uid)
    preferences = current_user.feed_preferences.where(feed_id: @feed.id).first_or_create

    @date = parse_date(params) || @feed.last_paper_date.to_date || Date.today
    @range = parse_range(params) || preferences.range
    @page = params[:page]

    preferences.pref_update!(@range)

    if @range == :since_last
      @range = ((Time.now - preferences.previous_last_visited) / 1.day).round
      @since_last = true
    end

    @backdate = @date - @range.days

    @recent_comments = _recent_comments(feed_uids)

    @scited_ids = current_user.scited_papers.pluck(:id)

    @papers = _range_query(feed_uids, @backdate, @date, @page)
  end
end
