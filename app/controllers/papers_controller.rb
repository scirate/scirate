class PapersController < ApplicationController
  def show
    @paper = Paper.includes(comments: :user).find_by_identifier!(params[:id])
  end

  def index
    @feed, @date = parse_params params

    @papers = @feed.papers.find_all_by_pubdate(@date)
    @papers = @papers.sort_by{ |p| [-p.scites.size, -p.comments.size, p.identifier] }

    #this is premature optimization, but it saves one query per unscited paper
    if signed_in?
      @scited_papers = Set.new( current_user.scited_papers )
    end
  end

  def next
    feed, date = parse_params params

    next_date = feed.next_date(date)

    if next_date.nil?
      flash[:error] = "No future papers found!"
      next_date = date
    end

    if feed.is_default?
      redirect_to papers_path(date: next_date)
    else
      redirect_to papers_path(date: next_date, feed: feed.name)
    end
  end

  def prev
    feed, date = parse_params params

    prev_date = feed.prev_date(date)

    if prev_date.nil?
      flash[:error] = "No past papers found!"
      prev_date = date
    end

    if feed.is_default?
      redirect_to papers_path(date: prev_date)
    else
      redirect_to papers_path(date: prev_date, feed: feed.name)
    end
  end

  private

    def parse_params params
      feed = Feed.find_by_name(params[:feed]) || Feed.default

      date = Chronic.parse(params[:date]) || feed.last_date
      date = date.to_date

      return [feed,date]
    end

end
