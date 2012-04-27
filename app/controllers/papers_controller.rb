class PapersController < ApplicationController
  include PapersHelper

  def show
    @paper = Paper.includes(comments: :user).find_by_identifier!(params[:id])
  end

  def index
    @date, @since = parse_date params
    @feed = parse_feed params

    if @feed.nil? && signed_in? && current_user.has_subscriptions?
      @date = last_date(current_user.feed) if @date.nil?
      @papers = fetch_papers current_user.feed.includes(:feed), @date, @since

      @feed_name = "#{current_user.name}'s feed"
      @feed = nil
    else
      @feed ||= Feed.default
      @date = last_date(@feed.papers) if @date.nil?

      @papers = fetch_papers @feed.papers, @date, @since
      @feed_name = @feed.name
    end

    @papers = @papers.sort_by{ |p| [-p.scites.size, -p.comments.size, p.identifier] }

    #this is premature optimization, but it saves one query per unscited paper
    if signed_in?
      @scited_papers = Set.new( current_user.scited_papers )
    end
  end

  def next
    date = parse_date(params)[0]
    feed = parse_feed params

    if feed.nil? && signed_in? && current_user.has_subscriptions?
       date ||= last_date(current_user.feed)

      papers = current_user.feed
    else
      feed ||= Feed.default
      date ||= last_date(feed.papers)

      papers = feed.papers
    end

    ndate = next_date(papers, date)

    if ndate.nil?
      flash[:error] = "No future papers found!"
      ndate = date
    end

    if params[:feed].nil?
      redirect_to papers_path(date: ndate)
    else
      redirect_to papers_path(date: ndate, feed: feed.name)
    end
  end

  def prev
    date = parse_date(params)[0]
    feed = parse_feed params

    if feed.nil? && signed_in? && current_user.has_subscriptions?
      date ||= last_date(current_user.feed)
      papers = current_user.feed
    else
      feed ||= Feed.default
      date ||= last_date(feed.papers)
      papers = feed.papers
    end

    pdate = prev_date(papers, date)

    if pdate.nil?
      flash[:error] = "No past papers found!"
      pdate = date
    end

    if params[:feed].nil?
      redirect_to papers_path(date: pdate)
    else
      redirect_to papers_path(date: pdate, feed: feed.name)
    end
  end

  private

    def parse_date params
      date = Chronic.parse(params[:date])
      date = date.to_date if !date.nil?

      since = Chronic.parse(params[:since])
      since = since.to_date if !since.nil?

      return date, since
    end

    def parse_feed params
      feed = Feed.find_by_name(params[:feed])

      return feed
    end

    def fetch_papers feed, date, since
      if since.nil?
        return feed.find_all_by_pubdate(date)
      else
        return feed.where("pubdate >= ? AND pubdate <= ?", since, date)
      end
    end
end
