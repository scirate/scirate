require 'open-uri'
require 'data_helpers'

class UsersController < ApplicationController
  before_action :signed_in_user,
           only: [:feeds, :edit, :update, :destroy, :settings, :settings_password]

  before_action :correct_user, only: [:edit, :update, :destroy]

  before_action :profile_data, only: [:activity, :papers, :scites, :comments, :download_scites]

  def profile_data
    @user = User.where("lower(username) = lower(?)", params[:username]).first!
  end

  def activity
    @tab = :activity
    @activities = @user.activity_feed(25)

    render 'users/profile'
  end

  def papers
    @tab = :papers
    @page = [1, params.fetch(:page, 1).to_s.to_i].max

    @authored_papers = @user.authored_papers.includes(:feeds, :authors).order('pubdate DESC').paginate(page: @page)
    @scited_by_uid = current_user.scited_by_uid(@authored_papers) if current_user

    render 'users/profile'
  end

  def scites
    @tab = :scites
    @page = [1, params.fetch(:page, 1).to_s.to_i].max

    @scited_papers = @user.scited_papers
      .order("scites.created_at DESC")
      .includes(:feeds, :authors)
      .paginate(page: @page, per_page: 10)

    @scited_by_uid = current_user.scited_by_uid(@scited_papers) if current_user

    render 'users/profile'
  end

  def download_scites
    @page = [1, params.fetch(:page, 1).to_s.to_i].max
    @per_page = 1000

    @scited_papers = @user.scited_papers
      .select("papers.*, scites.created_at as scite_created_at")
      .order("scites.created_at DESC")

    render json: @scited_papers[ [@scited_papers.length, @per_page * (@page - 1)].min, @per_page]
  end

  def comments
    @tab = :comments
    @page = [1, params.fetch(:page, 1).to_s.to_i].max

    @comments = @user.comments
      .where(hidden: false, deleted: false)
      .includes(:user, :paper)
      .paginate(page: @page, per_page: 20)

    render 'users/profile'
  end

  def new
    if !signed_in?
      @user = User.new
    else
      #flash[:error] = "Sign out to create a new user!"
      redirect_to root_path
    end
  end

  def create
    if !signed_in?
      default_username = User.default_username(params[:user][:fullname])
      @user = User.new(params.required(:user).permit(:fullname, :email, :password).merge(username: default_username, password_confirmation: params[:user][:password]))

      unless verify_recaptcha?(params["g-recaptcha-response"], 'submit')
        flash[:error] = "reCaptcha verification failed!"
        render 'new' and return
      end

      if @user.save
        @user.send_signup_confirmation
        sign_in @user
        redirect_to root_path and return
      else
        flash[:error] = "Unable to sign up user"
        render 'new'
      end   
     
    else
      flash[:error] = "Sign out to create a new user!"
      redirect_to root_path
    end
  end

  def edit
  end

  def destroy
    user = User.find_by_id(params[:id])

    if user == current_user
      user.destroy
      flash[:success] = "Your profile has been deleted."
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def activate
    user = User.find_by_id(params[:id])

    if user && !user.email_confirmed? && user.confirmation_token == params[:confirmation_token]

      if user.confirmation_sent_at > 2.days.ago
        user.activate
        flash[:success] = "Your account has been activated."
        sign_in(user)
        redirect_to root_url
      else
        user.send_signup_confirmation
        flash[:error] = "Confirmation link has expired: a new confirmation email has been sent to #{user.email}"
        redirect_to root_url
      end
    else
      flash[:error] = "Account is already active or link is invalid!"
      redirect_to root_url
    end
  end

  # Big feed subscriptions page
  def feeds
    @user = current_user
    @subscribed_ids = @user.subscriptions.pluck(:feed_uid)
  end

  def settings
    @user = current_user
    return unless request.post?

    old_email = @user.email

    user_params = params.required(:user)
                        .permit(:fullname, :email, :username, :url, :organization, :location, :author_identifier, :about, :show_jobs, :email_about_replies, :email_about_comments_on_authored, :email_about_comments_on_scited, :email_about_reported_comments)

    # Handle some varying input forms of author identifiers
    # e.g. https://twitter.com/fishcorn/status/476046077733261313
    aid = user_params[:author_identifier]
    if m = aid.match(/\/([^\/]+)\/?\Z/)
      aid = m[1]
    end
    user_params[:author_identifier] = aid.downcase

    begin
      if @user.update(user_params)
        if old_email != @user.email
          @user.send_email_change_confirmation(old_email)
          sign_in @user
        end

        sign_in @user
        flash[:success] = "Profile updated"
      else
        flash[:error] = @user.errors.full_messages
      end
    rescue OpenURI::HTTPError
      flash[:error] = "The arXiv doesn't seem to have that author identifier, please double check"
    end
  end

  def settings_password
    @user = current_user
    return unless request.post?

    if @user.password_digest.nil? || @user.authenticate(params[:current_password])
      if params[:new_password] == params[:confirm_password]
        if @user.change_password(params[:new_password])
          sign_in @user
          flash[:success] = "Password changed successfully"
        else
          flash[:error] = @user.errors.full_messages
        end
      else
        flash[:error] = "New password confirmation does not match"
      end
    else
      flash[:error] = "Current password is incorrect"
    end
  end

  private
    def correct_user
      @user = User.find_by_username(params[:username])
      unless current_user?(@user)
        redirect_to(root_path)
      end
    end

end
