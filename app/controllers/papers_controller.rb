class PapersController < ApplicationController
  include PapersHelper

  def show
    @paper = Paper.includes(comments: :user).find_by_identifier!(params[:id])
  end

  def index
    @date = parse_date params
    @feed = parse_feed params
    @range = parse_range params

    if @feed.nil? && signed_in? && current_user.has_subscriptions?
      @date ||= current_user.feed_updated_date
      @papers = fetch_papers current_user.feed.includes(:feed), @date, @range

      @feed_name = "#{current_user.name}'s feed"
      @feed = nil
    else
      @feed ||= Feed.default
      @date ||= @feed.updated_date

      @papers = fetch_papers @feed.cross_listed_papers.includes(:feed), @date, @range
      @feed_name = @feed.name
    end

    @papers = @papers.sort_by{ |p| [-p.scites.size, -p.comments.size, p.identifier] }

    #this is premature optimization, but it saves one query per unscited paper
    if signed_in?
      @scited_papers = Set.new( current_user.scited_papers )
    end
  end

  def next
    date = parse_date params
    feed = parse_feed params

    if feed.nil? && signed_in? && current_user.has_subscriptions?
       date ||= current_user.feed_updated_date

      papers = current_user.feed
    else
      feed ||= Feed.default
      date ||= feed.updated_date

      papers = feed.cross_listed_papers.includes(:feed)
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
      date ||= current_user.feed_updated_date
      papers = current_user.feed
    else
      feed ||= Feed.default
      date ||= feed.updated_date
      papers = feed.cross_listed_papers.includes(:feed)
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
      return feed.where("pubdate >= ? AND pubdate <= ?", date - range.days, date)
    end
end
