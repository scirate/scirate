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

  def _omniauth_link_to_existing(link)
    link.user = current_user
    link.save!
  end

  def omniauth_callback
    auth = env['omniauth.auth']

    link = AuthLink.from_omniauth(auth)

    if link.user.nil?
      if signed_in?
        # Link existing user to omniauth data
        _omniauth_link_to_existing(link)
      else
        # Create a new user with omniauth data
        _omniauth_new_user

      end

    else

    unless link.user.nil?
      sign_in link.user
      return redirect_back_or link.user
    end

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
      return redirect_to login_path
    end

    # Preserve this while we ask for confirmation
    session['omniauth.auth'] = auth

    render 'sessions/omniauth_confirm_new'
  end

  # Confirm creation of a new account from omniauth data
  def omniauth_create
    auth = session['omniauth.auth']

    link = AuthLink.from_omniauth(auth)
    user = link.create_user!

    sign_in user, remember_me: (params[:remember_me] == "1")
    redirect_back_or user
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
