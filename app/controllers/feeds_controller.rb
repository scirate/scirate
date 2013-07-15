class FeedsController < ApplicationController
  before_filter :find_feed, :only => [:subscribe, :unsubscribe]

  def show
    @feed = Feed.find_by_name(params[:feed])
    @date = @feed.last_paper_date

    @scited_papers = Set.new( current_user.scited_papers ) if signed_in?
    @papers = @feed.cross_listed_papers.paginate(page: params[:page])
    @papers = @papers.includes(:feed, :authors, :cross_lists => :feed)
    @papers = @papers.where("pubdate >= ? AND pubdate <= ?", @date, @date)
    @papers = @papers.order("scites_count DESC, comments_count DESC, identifier ASC")
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
