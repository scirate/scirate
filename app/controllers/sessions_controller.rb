class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      if user.active?
        sign_in user, remember_me: (params[:remember_me] == "1")
        redirect_back_or user
      else
        flash[:error] = 'Account is inactive!  Check your inbox for a confirmation mail.'
        redirect_to root_path        
      end
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'    
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
