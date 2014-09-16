require 'data_helpers'

class FeedsController < ApplicationController
  before_filter :parse_params

  # No user, and no feed specified: show all papers
  def index_nouser
    if @date.nil?
      @date = Feed.order("last_paper_date DESC").limit(1).pluck(:last_paper_date).first
    end

    @backdate = _backdate(@date, @range)
    @recent_comments = _recent_comments
    @papers, @pagination = _range_query(nil, @backdate, @date, @page)

    render 'feeds/show'
  end

  # Aggregated index feed
  def index
    return index_nouser unless signed_in?

    feed_uids = Rails.cache.fetch [:index_uids, current_user] do
      uids = current_user.subscriptions.pluck(:feed_uid)
      uids.concat Feed.where(parent_uid: uids).pluck(:uid)
    end

    if @date.nil? # No date specified
      if feed_uids.empty?
        # No subscriptions, this is fairly meaningless
        @date = end_of_today
      else
        @date = Feed.where(uid: feed_uids).order("last_paper_date DESC").pluck(:last_paper_date).first
      end
    end

    if @range == :since_last
      @range, @since_last = _since_last_visit(@date)
    end

    @backdate = _backdate(@date, @range)
    @recent_comments = _recent_comments(feed_uids)

    if feed_uids.empty?
      # No subscriptions
      @papers = []
    else
      @papers, @pagination = _range_query(feed_uids, @backdate, @date, @page)
    end

    @scited_by_uid = current_user.scited_by_uid(@papers)

    render 'feeds/show'
  end

  # Showing a feed while we aren't signed in
  def show_nouser
    @feed = Feed.find_by_uid!(params[:feed])
    feed_uids = Rails.cache.fetch [:feed_uids, @feed] do
      [@feed.uid] + @feed.children.pluck(:uid)
    end

    if @date.nil?
      @date = @feed.last_paper_date
    end

    @backdate = _backdate(@date, @range)
    @recent_comments = _recent_comments(feed_uids)
    @papers, @pagination = _range_query(feed_uids, @backdate, @date, @page)

    render 'feeds/show'
  end

  # Showing a feed
  def show
    return show_nouser unless signed_in?

    @feed = Feed.find_by_uid!(params[:feed])

    feed_uids = Rails.cache.fetch [:feed_uids, @feed] do
      [@feed.uid] + @feed.children.pluck(:uid)
    end

    @recent_comments = _recent_comments(feed_uids)

    # If no date is specified, default to the last date
    # with available papers
    if @date.nil?
      @date = @feed.last_paper_date
    end

    if @range == :since_last
      @range, @since_last = _since_last_visit(@date)
    end

    @backdate = _backdate(@date, @range)

    @papers, @pagination = _range_query(feed_uids, @backdate, @date, @page)
    @scited_by_uid = current_user.scited_by_uid(@papers)

    render 'feeds/show'
  end

  private

  def parse_params
    @date = _parse_date(params)
    @range = _parse_range(params) || :since_last
    @page = params[:page] || 1

    if @range == :since_last && !signed_in?
      # We don't know when the last value was here
      @range = 1
    end
  end

  def _parse_date(params)
    date = params[:date] ? Chronic.parse(params[:date]) : nil
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

  # Calculate time range based on when they last visited this page
  def _since_last_visit(date)
    preferences = current_user.feed_preferences.where(feed_uid: params[:feed]).first_or_create(last_visited: date, previous_last_visited: date)

    if preferences.last_visited.end_of_day <= date.end_of_day - 1.day
      preferences.previous_last_visited = preferences.last_visited
      preferences.last_visited = date
      preferences.save!
    end

    since_last = date.end_of_day - preferences.previous_last_visited.end_of_day
    range = [1, (since_last / 1.day).round].max

    [range, since_last]
  end

  # Go range days back from a given date
  def _backdate(date, range)
    (date - (range-1).days)
  end

  def _recent_comments(feed_uids=nil)
    query = if feed_uids.nil?
      Comment.joins(:user, :paper)
             .where(deleted: false, hidden: false, hidden_from_recent: false)
    else
      Comment.joins(:user, paper: :categories)
             .where(deleted: false, hidden: false, hidden_from_recent: false)
             .where(categories: { feed_uid: feed_uids })
    end

    query.order('comments.id DESC')
         .limit(10)
         .select('DISTINCT ON (comments.id) comments.id',
                 'comments.content',
                 'comments.created_at',
                 'comments.updated_at',
                 'papers.uid AS paper_uid',
                 'papers.title AS paper_title',
                 'users.username AS user_username',
                 'users.fullname AS user_fullname')
  end

  # The primary SciRate query. Given a set of feed uids, a pair of dates
  # to look between, and a page number, find a bunch of papers and order
  # them by relevance.
  #
  # This can be an expensive query, particularly for large date ranges.
  # We optimize by delegating to Elasticsearch instead of Postgres, which
  # is better suited for these kinds of tag queries.
  def _range_query(feed_uids, backdate, date, page)
    page = (page.nil? ? 1 : page.to_i)
    per_page = 50

    filters = [
      {
        range: {
          pubdate: {
           from: backdate.beginning_of_day,
           to: date.end_of_day
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
        { submit_date: 'desc' },
        { _id: 'desc' }
      ],
      query: {
        filtered: {
          filter: {
            :and => filters
          }
        }
      }
    }

    res = Search::Paper.es_find(query)

    papers_by_uid = map_models :uid, Paper.where(uid: res.documents.map(&:_id))

    papers = res.documents.map do |doc|
      paper = papers_by_uid[doc[:_id]]

      paper.authors_fullname = doc.authors_fullname
      paper.authors_searchterm = doc.authors_searchterm
      paper.feed_uids = doc.feed_uids

      paper
    end

    pagination = WillPaginate::Collection.new(page, per_page, res.raw.hits.total)

    return [papers, pagination]
  end
end
