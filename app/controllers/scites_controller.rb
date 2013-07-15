class ScitesController < ApplicationController
  before_filter :signed_in_user

  def create
    @paper = Paper.find(params[:paper_id])
    current_user.scite!(@paper)

    @scited_papers = [@paper]
    render partial: 'scites/toggle', object: @paper, as: :paper
  end

  def destroy    
    @paper = Paper.find(params[:paper_id])
    current_user.unscite!(@paper)

    @scited_papers = []
    render partial: 'scites/toggle', object: @paper, as: :paper
  end
end
