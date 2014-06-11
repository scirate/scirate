require 'data_helpers'

class FeedsController < ApplicationController
  before_filter :parse_params

  # No user, and no feed specified: show all papers
  def index_nouser
    if @date.nil?
      @date = Rails.cache.fetch [:last_paper_date, end_of_today] do
        Feed.order("last_paper_date DESC")
            .limit(1).pluck(:last_paper_date).first
      end
    end

    @backdate = @date - @range.days
    @recent_comments = _recent_comments
    @papers, @pagination = _range_query(nil, @backdate, @date, @page)

    render 'feeds/show'
  end

  # Aggregated index feed for a user
  def index
    feed_uids = Rails.cache.fetch [:index_uids, current_user] do
      uids = current_user.subscriptions.pluck(:feed_uid)
      uids.concat Feed.where(parent_uid: uids).pluck(:uid)
    end

    if @date.nil? # No date specified
      if feed_uids.empty? # User has no subscriptions; just default to today
        @date = end_of_today
      else
        @date = Rails.cache.fetch [:last_paper_date, feed_uids, end_of_today] do
          Feed.where(uid: feed_uids).order("last_paper_date DESC").pluck(:last_paper_date).first.at_end_of_day
        end
      end
    end

    @backdate = @date - @range.days
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
      @date = @feed.last_paper_date.at_end_of_day
    end

    @backdate = @date.at_end_of_day - @range.days
    @recent_comments = _recent_comments(feed_uids)
    @papers, @pagination = _range_query(feed_uids, @backdate, @date, @page)

    render 'feeds/show'
  end

  # Showing a feed normally
  def show
    @feed = Feed.find_by_uid!(params[:feed])

    feed_uids = Rails.cache.fetch [:feed_uids, @feed] do
      [@feed.uid] + @feed.children.pluck(:uid)
    end

    @recent_comments = _recent_comments(feed_uids)

    # If no date is specified, default to the last date
    # with available papers
    if @date.nil?
      @date = @feed.last_paper_date.at_end_of_day
    end

    @backdate = @date - @range.days

    @papers, @pagination = _range_query(feed_uids, @backdate, @date, @page)
    @scited_by_uid = current_user.scited_by_uid(@papers)

    render 'feeds/show'
  end

  private

  def parse_params
    @date = _parse_date(params)
    @range = _parse_range(params) || :since_last
    @page = params[:page] || 1

    if @range == :since_last && signed_in?
      # Define time range based on when they last visited this page
      @preferences = Rails.cache.fetch [:feed_preferences, current_user, params[:feed]] do
        current_user.feed_preferences.where(feed_id: params[:feed]).first_or_create
      end

      @since_last = end_of_today - @preferences.previous_last_visited.at_end_of_day
      @range = [1, (@since_last / 1.day).round].max
    elsif @range == :since_last && !signed_in?
      # We don't know when the last value was here
      @range = 1
    end
  end

  def _parse_date(params)
    date = params[:date] ? Chronic.parse(params[:date]).at_end_of_day : nil
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

  def _recent_comments(feed_uids=nil)
    query = if feed_uids.nil?
      Comment.joins(:user, :paper)
             .where(deleted: false, hidden: false, hidden_from_recent: false)
    else
      Comment.joins(:user, paper: :categories)
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

    res = Search::Paper.es_find(query)

    pagination = WillPaginate::Collection.new(page, per_page, res.raw.hits.total)

    return [res.documents, pagination]
  end
end
