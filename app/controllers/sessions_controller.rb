class SessionsController < ApplicationController
  def new
  
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      log_in user 
      flash[:success] = "You're Logged in"
      redirect_to user_path(user.id)
    else
      flash.now[:danger] = "Invalid Username or Email"
      render :new
    end
  end

  def destroy
      flash[:success] = "You've Successfully logged out!"
      logout 
      redirect_to root_path
  end
end
