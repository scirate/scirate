class PapersController < ApplicationController
  def show
    @paper = Paper.includes(comments: :user).find_by_identifier!(params[:id])    
  end

  def index
    #This is done on multiple lines to avoid an error if find returns nil
    last = Paper.find(:first, order: "pubdate DESC")
    last = last.nil? ? Date.today : last.pubdate

    @date = Chronic.parse(params[:date]) || last
    @date = @date.to_date

    @next = nil

    #this test saves a query on the most recent date
    if @date != last     
      @next = Paper.find(:last, 
                         order: "pubdate DESC", 
                         conditions: ["pubdate > ?", @date])
      @next = @next.pubdate unless @next.nil?
    end

    @prev = Paper.find(:first, 
                          order: "pubdate DESC", 
                          conditions: ["pubdate < ?", @date])
    @prev = @prev.pubdate unless @prev.nil?

    @papers = Paper.find_all_by_pubdate(@date)
    @papers = @papers.sort_by{ |p| [-p.scites.size, -p.comments.size, p.identifier] }

    #this is premature optimization, but it saves one query per unscited paper
    if signed_in?
      @scited_papers = Set.new( current_user.scited_papers )      
    end
  end
end
