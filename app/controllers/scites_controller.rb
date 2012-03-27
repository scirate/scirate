class ScitesController < ApplicationController
  before_filter :signed_in_user

  def create
    @paper = Paper.find(params[:scite][:paper_id])
    current_user.scite!(@paper)

    respond_to do |format|
      format.html { redirect_to(:back) }
      format.js
    end
  end

  def destroy    
    @paper = Paper.find(params[:paper_id])
    current_user.unscite!(@paper)

    respond_to do |format|
      format.html { redirect_to(:back) }
      format.js
    end
  end
end
