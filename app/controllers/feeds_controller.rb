require 'data_helpers'

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

    @recent_comments = later { Comment.visible.where(hidden_from_recent: false).order("created_at DESC").limit(10) }

    @papers, @pagination = later { _range_query(nil, @backdate, @date, @page) }

    render 'feeds/show'
  end

  # Aggregated feed
  def index
    return landing unless signed_in?

    parent_uids = current_user.feeds.pluck(:uid)
    feed_uids = parent_uids + Feed.where(parent_uid: parent_uids).pluck(:uid)

    @preferences = later { current_user.feed_preferences.where(feed_id: nil).first_or_create }

    @date = _parse_date(params)

    if @date.nil?
      if feed_uids.empty?
        @date = Date.today
      else
        @date = (Feed.where(uid: feed_uids).order("last_paper_date DESC").pluck(:last_paper_date).first || Date.today).to_date
      end
    end

    @range = _parse_range(params) || :since_last# || @preferences.range
    @page = params[:page] || 1

    if @range == :since_last
      @range = [1, (Date.today - @preferences.previous_last_visited.to_date).to_i].max
      @since_last = true
    end

    @backdate = @date - (@range-1).days
    # Remember what time range they selected

    @recent_comments = later { _recent_comments(feed_uids) }

    if feed_uids.empty?
      # No subscriptions
      @papers = []
    else
      @papers, @pagination = later { _range_query(feed_uids, @backdate, @date, @page) }
    end

    @scited_by_uid = later { current_user.scited_by_uid(@papers) }

    later { @preferences.pref_update!(@range) }

    render 'feeds/show'
  end

  # Showing a feed while we aren't signed in
  def show_nouser
    @feed = later { Feed.find_by_uid!(params[:feed]) }
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

    @recent_comments = later { _recent_comments(feed_uids) }

    @papers, @pagination = later { _range_query(feed_uids, @backdate, @date, @page) }
  end

  def show
    return show_nouser unless signed_in?

    @feed = later { Feed.find_by_uid!(params[:feed]) }
    @preferences = later { current_user.feed_preferences.where(feed_id: nil).first_or_create }
    feed_uids = [@feed.uid] + @feed.children.pluck(:uid)
    @recent_comments = later { _recent_comments(feed_uids) }

    @date = (_parse_date(params) || @feed.last_paper_date || Date.today).to_date
    @range = _parse_range(params) || :since_last# || @preferences.range
    @page = params[:page]

    if @range == :since_last
      @range = [1, (@date - @preferences.previous_last_visited.to_date).to_i].max
      @since_last = true
    end

    @backdate = @date - (@range-1).days

    @papers, @pagination = later { _range_query(feed_uids, @backdate, @date, @page) }
    @scited_by_uid = later { current_user.scited_by_uid(@papers) }

    later { @preferences.pref_update!(@range) }
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
    ids = Comment.find_all_by_feed_uids(feed_uids).limit(10).pluck(:id)
    Comment.includes(:user, :paper)
           .where(id: ids)
           .index_by(&:id)
           .slice(*ids)
           .values
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
    per_page = 70

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
      fields: ['_id'],
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
    paper_uids = res.documents.map(&:_id)

    pagination = WillPaginate::Collection.new(page, per_page, res.raw.hits.total)

    papers = Paper.includes(:authors, :feeds)
                  .where(uid: paper_uids)
                  .index_by(&:uid)
                  .slice(*paper_uids)
                  .values

    return [papers, pagination]
  end
end
