class ScitesController < ApplicationController
  before_filter :signed_in_user

  def create
    @paper = Paper.find(params[:scite][:paper_id])
    current_user.scite!(@paper)
    redirect_to(:back)    
  end

  def destroy
    @paper = Scite.find(params[:id]).paper
    current_user.unscite!(@paper)
    redirect_to(:back)    
  end
end
