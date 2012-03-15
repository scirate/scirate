class PapersController < ApplicationController
  def show
    identifier = "#{params[:id]}.#{params[:format]}"    
    @paper = Paper.find_by_identifier!(identifier)
  end

  def index
    #Update me to show only papers from a given date
    @papers = Paper.all
  end
end
