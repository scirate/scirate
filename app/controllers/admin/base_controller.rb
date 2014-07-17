class Admin::BaseController < ApplicationController
  before_filter :signed_in_user, :require_admin

  def require_admin
    unless current_user.is_admin?
      flash[:error] = "You don't have permission to do that!"
      redirect_to root_url
    end
  end

  def _site_data(from, to)
    data = {}
    data[:scites] = Scite.where("created_at > ? AND created_at < ?", from, to).includes(:user)
    data[:papers] = Paper.where("pubdate > ? AND pubdate < ?", from, to)
    data[:comments] = Comment.visible.where("created_at > ? AND created_at < ?", from, to)
    data[:active_users] = data[:scites].map(&:user).uniq
    data[:new_users] = User.where("created_at > ? AND created_at < ?", from, to)
    data[:best_paper] = Paper.where("pubdate > ? AND pubdate < ?", from, to).order("scites_count DESC")[0]
    data
  end

  def index
    now = Time.now

    @weeks = 0.upto(5).map do |i|
      _site_data(now - (7*(i+1)).days, now - (7*i).days)
    end

    render 'admin/index'
  end

  def alert
    System.alert = params[:alert]
    System.save
    redirect_to admin_path
  end
end
