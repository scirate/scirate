class PasswordResetsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])

    if (user && user.active?)
      user.send_password_reset
      redirect_to root_url, :notice => "Email sent with password reset instructions."
    else
      flash[:error] = "Email address not found!"
      render 'new'
    end
  end

  def edit
    @user = User.find_by_password_reset_token(params[:id])

    if @user.nil?
      redirect_to root_url, :notice => "Password reset has already been used or is invalid!"
    end
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])

    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    else 
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      if @user.save
        @user.clear_password_reset
        sign_in(@user)
        redirect_to root_url, :notice => "Password has been changed!"
      else
        render :edit
      end
    end
  end
end
