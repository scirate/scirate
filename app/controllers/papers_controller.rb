class PapersController < ApplicationController
  def show
    identifier = "#{params[:id]}.#{params[:format]}"    
    @paper = Paper.find_by_identifier!(identifier)
  end

  def index
    @date = Chronic.parse(params[:date])
    if @date.nil?
      @date = Date.today
    else
      @date = @date.to_date
    end

    @papers = Paper.find_all_by_pubdate(@date)
  end
end
