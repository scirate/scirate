class UsersController < ApplicationController
  before_filter :signed_in_user, 
           only: [:show, :edit, :update, :destroy]

  before_filter :correct_user,   only: [:edit, :update, :destroy]

  def show
    @user = User.find(params[:id])
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
        if !signed_in?
          sign_in @user
        end
        
        flash[:success] = "Welcome to Scirate!"
        redirect_to @user
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
    if @user.update_attributes(params[:user])
      sign_in @user
      flash[:success] = "Profile updated"
      render 'show'
    else
      render 'edit'
    end   
  end 

  def destroy
    user = User.find(params[:id])

    if user == current_user
      user.destroy
      flash[:success] = "Your profile has been deleted."
      redirect_to root_path
    else
      redirect_to root_path
    end  
  end

  def scited_papers
    @user = User.find(params[:id])
  end

  private

    def correct_user
      @user = User.find(params[:id])      
      redirect_to(root_path) unless current_user?(@user)
    end

end
