class AdminController < ApplicationController
  before_filter :signed_in_user, :require_admin

  def edit_user
    @user = User.find_by_username!(params[:username])
  end

  def update_user
    @user = User.find_by_username!(params[:username])

    old = @user.attributes.dup

    user_params = 
      params.required(:user)
            .permit(:fullname, :username, :email, :account_status)

    if @user.update_attributes(user_params)
      if old['email'] != @user.email
        @user.send_email_change_confirmation(old['email'])
      end
      
      flash[:success] = "User updated"
    end

    render 'edit_user'
  end

  private
    def require_admin
      unless current_user.is_admin?
        flash[:error] = "You don't have permission to do that!"
        redirect_to root_path
      end
    end
end
