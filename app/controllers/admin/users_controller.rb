module Admin
  class UsersController < BaseController
    before_action :load_user

    def edit
    end

    def become
      sign_in @user
      flash[:success] = "You are now signed in as #{@user.username}"
      redirect_to root_path
    end

    def update
      old = @user.attributes.dup

      user_params = params.required(:user)
        .permit(:fullname, :email, :username, :url, :organization, :location,
                :author_identifier, :about, :account_status)

      if @user.update(user_params)
        if old['email'] != @user.email
          @user.send_email_change_confirmation(old['email'])
        end

        flash[:success] = 'User has been successfully updated.'
      else
        flash[:error] = 'Failed to update user.'
      end

      render 'edit'
    end

    private

    def load_user
      @user = User.where("lower(username) = lower(?)", params[:username]).first!
    end
  end
end
