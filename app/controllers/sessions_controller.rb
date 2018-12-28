class SessionsController < ApplicationController
  def new
    
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)

    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user 
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        flash[:success] = "You're Logged in"
        redirect_back_or user_path(@user.id)
      else 
        message = "Account not activated"
        message += "Check your email for the activation link"
        flash[:warning] = message
        redirect_to root_path
      end
    else
      flash.now[:danger] = "Invalid Username or Email"
      render :new
    end
  end

  def destroy
      flash[:success] = "You've Successfully logged out!" if logged_in?
      logout if logged_in?
      redirect_to root_path
  end
end
