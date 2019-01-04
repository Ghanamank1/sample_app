class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  def index
    # only showing users that are activated 
    # in the index page i.e. /users path 
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    # showing user profile only if they are activated
    redirect_to root_path and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create 
    @user = User.new(user_params)

    if @user.save
      # sends an activation email and link
      @user.send_activation_email # send method define in user model
      flash[:info] = "Please check your email to activate your account"
      redirect_to root_path

      # BEFORE WE ADDED ACCOUNT ACTIVATION
      # log_in @user
      # flash[:success] = "Welcome to Sample App!"
      # redirect_to user_path(@user)
    else
      render :new
    end
  end

  def edit 
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to user_path(@user)
    else
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:success] = "User: #{user.name}, deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    # Before filters

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user) 
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
