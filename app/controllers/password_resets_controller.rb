class PasswordResetsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])

    if (user && user.active?)
      user.send_password_reset
      flash[:success] = "Email sent with password reset instructions."
      redirect_to root_url
    else
      flash[:error] = "Email address not found!"
      render :new
    end
  end

  def confirm
    @user = User.find_by_password_reset_token(params[:id])

    if @user.nil?
      flash[:error] = "Password reset has already been used or is invalid!"
      redirect_to root_url
    end
  end

  def submit
    @user = User.find_by_password_reset_token!(params[:id])

    if @user.password_reset_sent_at < 2.hours.ago
      flash[:warning] = "Password reset has expired."
      redirect_to reset_password_path
    elsif params[:password] != params[:password_confirmation]
      flash[:error] = "Password doesn't match confirmation"
      render :confirm
    else
      @user.change_password!(params[:password])
      @user.clear_password_reset
      sign_in(@user)
      flash[:success] = "Password has been changed!"
      redirect_to root_url
    end
  end
end
