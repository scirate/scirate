class PapersController < ApplicationController
  def show
    @paper = Paper.includes(comments: :user).find_by_identifier!(params[:id])    
  end

  def index
    @date = Chronic.parse(params[:date]) || Paper.last_date
    @date = @date.to_date

    @papers = Paper.find_all_by_pubdate(@date)
    @papers = @papers.sort_by{ |p| [-p.scites.size, -p.comments.size, p.identifier] }

    #this is premature optimization, but it saves one query per unscited paper
    if signed_in?
      @scited_papers = Set.new( current_user.scited_papers )      
    end
  end

  def next
    date = Chronic.parse(params[:date]) || Paper.last_date
    date = date.to_date

    next_date = Paper.next_date(date)

    if next_date.nil?
      flash[:error] = "No future papers found!"
      next_date = date
    end

    redirect_to papers_path(date: next_date)
  end

  def prev
    date = Chronic.parse(params[:date]) || Paper.last_date
    date = date.to_date

    prev_date = Paper.prev_date(date)

    if prev_date.nil?
      flash[:error] = "No past papers found!"
      prev_date = date
    end

    redirect_to papers_path(date: prev_date)
  end
end
