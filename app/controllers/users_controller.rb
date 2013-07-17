class UsersController < ApplicationController
  before_filter :signed_in_user,
           only: [:show, :edit, :update, :destroy, :settings, :settings_password]

  before_filter :correct_user, only: [:edit, :update, :destroy]

  def show
    @user = User.find(params[:id])

    if params[:scite_order] == 'published'
      @scite_order = :published
      @scited_papers = @user.scited_papers.order("pubdate DESC")
    else
      @scite_order = :scited
      @scited_papers = @user.scited_papers.order("scites.created_at DESC")
    end
    
    @scited_papers = @scited_papers.paginate(page: params[:scite_page], per_page: 10)
    @comments = @user.comments.paginate(page: params[:comment_page], per_page: 20)
  end

  def new
    if !signed_in?
      @user = User.new
    else
      flash[:error] = "Sign out to create a new user!"
      redirect_to root_path
    end
  end

  def create
    if !signed_in?
      @user = User.new(params[:user])
      if @user.save
        @user.send_signup_confirmation
        flash[:success] = "Welcome to Scirate!  Confirmation mail sent to: #{@user.email}"
        redirect_to root_path
      else
        render 'new'
      end
    else
      flash[:error] = "Sign out to create a new user!"
      redirect_to root_path
    end
  end

  def edit
  end

  def update
    if !current_user.is_admin? && !@user.authenticate(params[:user][:old_password])
      flash[:error] = "Old password is incorrect!"
      render 'edit'
      return
    end

    if params[:user][:account_status]
      unless current_user.is_admin?
        flash[:error] = "Admin status required"
        render 'edit'
        return
      end

      unless @user.change_status(params[:user][:account_status])
        render 'edit'
        return
      end
    end

    old_email = @user.email

    if @user.update_attributes(params[:user].slice(:name,:email,:password,:password_confirmation, :expand_abstracts))
      if old_email != @user.email
        @user.send_email_change_confirmation(old_email)
      end

      sign_in @user if current_user.id == @user.id
      flash[:success] = "Profile updated"
    end

    render 'edit'
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

    if user && !user.active? && user.confirmation_token == params[:confirmation_token]

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
      redirect_to root_url, :notice => "Account is already active or link is invalid!"
    end
  end

  def scited_papers
    @user = User.find(params[:id])
    @papers = @user.scited_papers.paginate(page: params[:page]).includes(:feed)
  end

  def comments
    @user = User.includes(comments: :paper).find(params[:id])
  end

  def subscriptions
    @user = User.find(params[:id])
    @feeds = Feed.order("name")

    # This is to avoid loading each subscription individually.  There is
    # presumably some way to do this with eager loading, but I cannot make
    # rails use the eager-loaded data for feeds the user is not subscribed to.
    @subscriptions = Set.new( @user.subscriptions.map { |s| s.feed_id } )
  end

  def settings
    @user = current_user
  end

  def settings_password
    @user = current_user
    return unless request.post?

    if @user.authenticate(params[:current_password])
      @user.change_password!(params[:new_password])
      flash[:success] = "Password changed successfully"
    else
      flash[:error] = "Current password is incorrect"
    end
  end

  private
    def correct_user
      # Ensure current user has permission to edit this user
      @user = User.find(params[:id])
      unless current_user?(@user) || current_user.is_admin?
        redirect_to(root_path)
      end
    end

end
