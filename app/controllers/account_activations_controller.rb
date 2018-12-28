class AccountActivationsController < ApplicationController
    
    def edit
        user = User.find_by(email: params[:email])
        if user && !user.activated? && user.authenticated?(:activation, params[:id])
            # activates the user (database)
            user.activate # activate define in user model          
            
            log_in(user)
            flash[:success] = "Account activated"

            # Goes to the user profile 
            redirect_to user_path(user)
        else
            flash[:danger] = "Invalid activation link"
            redirect_to root_url
        end
    end
end
