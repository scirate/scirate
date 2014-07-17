class SessionsController < ApplicationController
  def new
  end

  def create
    session[:return_to] = params[:return_to] if params[:return_to]

    user = User.find_by_email(params[:email_or_username]) ||
           User.find_by_username(params[:email_or_username])

    if user && user.authenticate(params[:password])
      sign_in user, remember_me: (params[:remember_me] == "1")
      redirect_back_or root_path
    else
      flash.now[:error] = "Invalid email/password combination"
      render 'new'
    end
  end

  def _omniauth_link_to_existing(link)
    link.user = current_user
    link.save!
    flash[:success] = "Your account was linked to Google successfully."
    redirect_to settings_path
  end

  # Need to ask for confirmation before creating a new user via omniauth.
  # Otherwise people may accidentally generate new accounts when what
  # they really wanted was to link their existing account to Google.
  def _omniauth_confirm_new(link)
    @email = link.auth.info.email

    if User.where(email: @email).exists?
      # Account with this email already created, but
      # using a different auth method.
      flash[:error] = "The email address #{@email} is already associated with a SciRate account. To connect your account to Google please visit your settings page."
      return redirect_to login_path
    end

    # Preserve this while we wait for the user
    session['omniauth.auth'] = link.auth

    render 'sessions/omniauth_confirm_new'
  end

  def omniauth_callback
    auth = env['omniauth.auth']
    link = AuthLink.from_omniauth(auth)

    if signed_in?
      if link.user.nil?
        # Link existing user to omniauth data
        logger.info("Linking user '#{current_user.username}' to '#{auth.info.email}'")
        _omniauth_link_to_existing(link)
      elsif link.user.id == current_user.id
        # Already linked, pretend we did something useful
        logger.info("User '#{current_user.username}' already linked to '#{auth.info.email}', redirecting")
        flash[:success] = "Your account was linked to Google successfully."
        redirect_to settings_path
      else
        # Already linked to another user
        logger.info("Failed to link user '#{current_user.username}' to '#{auth.info.email}': already linked to another user")
        flash[:error] = "This Google account is already linked to another user. Please sign in with Google and disconnect the link."
        redirect_to settings_path
      end
    else
      if link.user.nil?
        # Create a new user with omniauth data
        logger.info("Creating new account via omniauth for '#{auth.info.email}'")
        _omniauth_confirm_new(link)
      else
        # Matched existing link, sign them in
        logger.info("Matched omniauth '#{auth.info.email}' to user '#{link.user.username}', signing in")
        sign_in link.user
        redirect_back_or root_path
      end
    end
  end

  def omniauth_disconnect
    if current_user.password_digest.nil?
      flash[:error] = "Please add a password first. If you disconnect your Google account without a password, you won't be able to log in."
      redirect_to settings_path
    else
      current_user.auth_links.destroy_all
      flash[:success] = "Google account disconnected successfully."
      redirect_to settings_path
    end
  end

  # Confirm creation of a new account from omniauth data
  def omniauth_create
    auth = session['omniauth.auth']
    session['omniauth.auth'] = nil

    link = AuthLink.from_omniauth(auth)
    user = link.create_user!

    sign_in user, remember_me: (params[:remember_me] == "1")
    redirect_back_or root_path
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
