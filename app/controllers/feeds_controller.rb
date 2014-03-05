class FeedsController < ApplicationController
  def landing
    @date = _parse_date(params)

    if @date.nil?
      feed = Feed.order("last_paper_date DESC").first
      @date = (feed && feed.last_paper_date) ? feed.last_paper_date.to_date : Date.today
    end

    @range = _parse_range(params) || 1
    @page = params[:page] || 1

    @backdate = @date - (@range-1).days

    @recent_comments = Comment.order("created_at DESC").limit(10)

    @scited_ids = []

    @papers = _range_query(nil, @backdate, @date, @page)

    render 'feeds/show'
  end

  # Aggregated feed
  def index
    return landing unless signed_in?

    feeds = current_user.feeds.includes(:children)
    feed_uids = feeds.map(&:uid) + feeds.map(&:children).flatten.map(&:uid)

    @preferences = current_user.feed_preferences.where(feed_id: nil).first_or_create

    @date = _parse_date(params)

    if @date.nil?
      if feed_uids.empty?
        @date = Date.today
      else
        @date = Feed.where(uid: feed_uids).order("last_paper_date DESC").first.last_paper_date.to_date || Date.today
      end
    end

    @range = _parse_range(params) || :since_last# || @preferences.range
    @page = params[:page] || 1

    if @range == :since_last
      @range = [1, (@date - @preferences.previous_last_visited.to_date).to_i].max
      @since_last = true
    end

    @backdate = @date - (@range-1).days
    # Remember what time range they selected
    @preferences.pref_update!(@range)

    @recent_comments = _recent_comments(feed_uids)

    @scited_ids = current_user.scited_papers.pluck(:id)

    if feed_uids.empty?
      # No subscriptions
      @papers = []
    else
      @papers = _range_query(feed_uids, @backdate, @date, @page)
    end

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
    Comment.find_by_feed_uids(feed_uids).limit(10)
  end

  # The primary SciRate query. Given a set of feed uids, a pair of dates
  # to look between, and a page number, find a bunch of papers and order
  # them by relevance.
  #
  # This can be an expensive query, particularly for large date ranges.
  # We optimize by using the denormalized crosslist_date on categories
  # to allow index use and prevent scanning two tables at once. This is
  # functionally identical to pubdate.
  def _range_query(feed_uids, backdate, date, page)
    page = (page.nil? ? 1 : page.to_i)
    per_page = 100

    filters = [
      { 
        range: {
          pubdate: {
           from: backdate,
           to: date
          }
        } 
      },
    ]

    filters << {terms: {feed_uids: feed_uids}} unless feed_uids.nil?

    query = {
      size: per_page,
      from: (page-1)*per_page,
      sort: [
        { scites_count: 'desc' },
        { comments_count: 'desc' },
        { pubdate: 'desc' },
        { submit_date: 'desc' }
      ],
      query: {
        filtered: {
          filter: {
            :and => filters         
          }
        }
      }
    }

    res = Search::Paper.find(query)
    paper_uids = res.documents.map(&:_id)

    @pagination = WillPaginate::Collection.new(page, per_page, res.raw.hits.total)

    papers = Paper.includes(:authors, :feeds)
                  .where(uid: paper_uids)
                  .index_by(&:uid)
                  .slice(*paper_uids)
                  .values

    return papers
  end
end
