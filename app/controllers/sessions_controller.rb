class SessionsController < ApplicationController
  def new
  end

  def create
    session[:return_to] = params[:return_to] if params[:return_to]

    user = User.find_by_email(params[:email_or_username]) ||
           User.find_by_username(params[:email_or_username])

    if user && user.authenticate(params[:password])
      sign_in user, remember_me: (params[:remember_me] == "1")
      redirect_back_or user
    else
      flash.now[:error] = "Invalid email/password combination"
      render 'new'
    end
  end

  # Sign in with an omniauth provider, creating a
  # new user if necessary
  def omniauth_create
    auth = env['omniauth.auth']

    begin
      link = AuthLink.from_omniauth(auth)
    rescue ActiveRecord::RecordInvalid => e
      # Account with this email already created, but
      # using a different auth method.
      if e.message.include? "Email has already been taken"
        if auth.provider == 'google_oauth2'
          provider = "Google"
        else
          provider = auth.provider.capitalize
        end

        flash[:error] = "The email address #{auth.info.email} is already associated with a SciRate account. To connect your account to #{provider} please visit your settings page."
        return render 'sessions/new'
      else
        raise
      end
    end

    user = link.user
    sign_in user, remember_me: (params[:remember_me] == "1")
    redirect_back_or user
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
