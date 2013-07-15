class FeedsController < ApplicationController
  before_filter :find_feed, :only => [:subscribe, :unsubscribe]

  def show
    @feed = Feed.find_by_name(params[:feed])
    @date = parse_date(params) || @feed.last_paper_date
    @range = parse_range(params)
    @page = params[:page]

    @recent_comments = Comment.joins(:paper)
                              .where(:paper => { :feed_id => @feed.id })
                              .order("created_at DESC")
    @scited_papers = Set.new( current_user.scited_papers ) if signed_in?

    @papers = Paper.range_query(@feed.cross_listed_papers, @date, @range, @page)
  end

  def subscribe
    @feed.subscriptions.find_or_create_by_user_id(current_user.id)
    render :partial => 'subscribe', :locals => { :feed => @feed }
  end

  def unsubscribe
    @feed.subscriptions.where(user_id: current_user.id).destroy_all
    render :partial => 'subscribe', :locals => { :feed => @feed }
  end

  protected
    def find_feed
      @feed = Feed.find(params[:id])
    end
end
