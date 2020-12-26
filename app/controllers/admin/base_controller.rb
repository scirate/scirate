require 'data_helpers'

class Admin::BaseController < ApplicationController
  before_action :signed_in_user, :require_admin

  def require_admin
    unless current_user.can_admin?
      flash[:error] = "You don't have permission to do that!"
      redirect_to root_url
    end
  end

  def _site_data(from, to)
    data = {}
    scites = Scite.where("created_at > ? AND created_at < ?", from, to).includes(:user)
    data[:scites] = scites.count
    data[:papers] = Paper.where("pubdate > ? AND pubdate < ?", from, to).count
    data[:comments] = Comment.visible.where("created_at > ? AND created_at < ?", from, to).count
    data[:active_users] = scites.map(&:user).uniq.count
    data[:new_users] = User.where("created_at > ? AND created_at < ?", from, to).count
    data[:best_paper] = Paper.where("pubdate > ? AND pubdate < ?", from, to).order("scites_count DESC")[0]
    data
  end

  def index
    now = Time.now

    @weeks = Rails.cache.fetch [:admin_stats, end_of_today] do
      0.upto(10).map do |i|
        _site_data(now - (7*(i+1)).days, now - (7*i).days)
      end
    end

    render 'admin/index'
  end

  def alert
    System.alert = params[:alert]
    System.save
    redirect_to admin_path
  end
end
