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

  # We have the information needed to sign in.
  # However, the account may not exist, in which case:
  # - Need to check that the email isn't taken
  # - Ask for confirmation in case they didn't want a new account
  def omniauth_check
    auth = env['omniauth.auth']

    link = AuthLink.from_omniauth(auth)

    if auth.provider == 'google_oauth2'
      @provider = "Google"
    else
      @provider = auth.provider.capitalize
    end

    @email = auth.info.email

    if link.user.nil? && User.where(email: auth.info.email).exists?
      # Account with this email already created, but
      # using a different auth method.
      flash[:error] = "The email address #{auth.info.email} is already associated with a SciRate account. To connect your account to #{@provider} please visit your settings page."
      redirect_to login_path and return
    end

    # Preserve this while we ask for confirmation
    session['omniauth.auth'] = auth

    render 'sessions/omniauth_confirm_new'
  end

  # Sign in with an omniauth provider, creating a
  # new user if necessary
  def omniauth_create
    auth = session['omniauth.auth']

    link = AuthLink.from_omniauth(auth)
    user = link.create_user!(auth)

    sign_in user, remember_me: (params[:remember_me] == "1")
    redirect_back_or user
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
