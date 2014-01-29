class FeedsController < ApplicationController
  def landing
    @feeds = Feed.map_uids
    render('papers/landing', :layout => nil)
  end

  # Aggregated feed
  def index
    return landing unless signed_in?

    feeds = current_user.feeds.includes(:children)
    feed_uids = feeds.map(&:uid) + feeds.map(&:children).flatten.map(&:uid)

    @preferences = current_user.feed_preferences.where(feed_id: nil).first_or_create

    @date = _parse_date(params) || Feed.where(uid: feed_uids).order("last_paper_date DESC").first.last_paper_date.to_date || Date.today
    @range = _parse_range(params) || :since_last# || @preferences.range
    @page = params[:page]

    if @range == :since_last
      @range = [1, (@date - @preferences.previous_last_visited.to_date).to_i].max
      @since_last = true
    end

    @backdate = @date - (@range-1).days
    # Remember what time range they selected
    @preferences.pref_update!(@range)

    @recent_comments = _recent_comments(feed_uids)

    @scited_ids = current_user.scited_papers.pluck(:id)

    @papers = _range_query(feed_uids, @backdate, @date, @page)

    render 'feeds/show'
  end

  # Showing a feed while we aren't signed in
  def show_nouser
    @feed = Feed.find_by_uid!(params[:feed])
    feed_uids = [@feed.uid] + @feed.children.pluck(:uid)

    @date = (_parse_date(params) || @feed.last_paper_date || Date.today).to_date
    @range = _parse_range(params) || 1
    @page = params[:page]

    if @range == :since_last
      # If we're not signed in, there's no sense
      # in which we can do "since last"
      @range = 1
    end

    @backdate = @date - (@range-1).days

    @recent_comments = _recent_comments(feed_uids)

    @papers = _range_query(feed_uids, @backdate, @date, @page)
  end

  def show
    return show_nouser unless signed_in?

    @feed = Feed.find_by_uid!(params[:feed])
    feed_uids = [@feed.uid] + @feed.children.pluck(:uid)
    @preferences = current_user.feed_preferences.where(feed_id: nil).first_or_create

    @date = (_parse_date(params) || @feed.last_paper_date || Date.today).to_date
    @range = _parse_range(params) || :since_last# || @preferences.range
    @page = params[:page]

    @preferences.pref_update!(@range)

    if @range == :since_last
      @range = [1, (@date - @preferences.previous_last_visited.to_date).to_i].max
      @since_last = true
    end

    @backdate = @date - (@range-1).days

    @recent_comments = _recent_comments(feed_uids)

    @scited_ids = current_user.scited_papers.pluck(:id)

    @papers = _range_query(feed_uids, @backdate, @date, @page)
  end

  private

  def _parse_date(params)
    date = Chronic.parse(params[:date])
    date = date.to_date unless date.nil?

    return date
  end

  def _parse_range(params)
    return nil unless params.has_key?(:range)
    return :since_last if params[:range] == 'since_last'

    range = params[:range].to_i

    # negative date windows are confusing
    range = 0 if range < 0

    return range
  end

  def _recent_comments(feed_uids)
    @recent_comments = Comment.joins(:paper, paper: :categories)
                              .where(hidden: false, paper: { categories: { feed_uid: feed_uids } })
                              .group('comments.id')
                              .order("comments.created_at DESC").limit(10)
  end

  # The primary SciRate query. Given a set of feed uids, a pair of dates
  # to look between, and a page number, find a bunch of papers and order
  # them by relevance.
  #
  # This can be an expensive query, particularly for large date ranges.
  # We optimize by using the denormalized crosslist_date on categories
  # to allow index use and prevent scanning two tables at once. This is
  # functionally identical to pubdate.
  #
  # NOTE (Mispy): Could this be improved somehow by using Sphinx?
  def _range_query(feed_uids, backdate, date, page)
    @range_query =
      Paper.joins(:categories)
        .where("categories.feed_uid IN (?) AND categories.crosslist_date >= ? AND categories.crosslist_date < ?", feed_uids, backdate, date+1.day)
        .order("scites_count DESC, comments_count DESC, pubdate DESC")
        .paginate(per_page: 30, page: page)

    paper_ids = @range_query.pluck(:id)

    papers = Paper.includes(:authors, :feeds)
                  .where(id: paper_ids)
                  .index_by(&:id)
                  .slice(*paper_ids)
                  .values

    return papers
  end
end
