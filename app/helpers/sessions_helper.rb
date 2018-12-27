module SessionsHelper

    # logs in the given user 
    def log_in(user)
        session[:user_id] = user.id
    end

    # Returns true if the user is logged in, false otherwise
    def logged_in?
        !current_user.nil?
    end

    # Logs out the current user
    def logout
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end

    # Returns true if the given user is the current user.
    def current_user?(user)
        user == current_user
    end

    # Returns the current logged-in user (if any)
     def current_user 
        # first checks if the user is already logged in
        # if the user is logged in then it just assigns 
        # current user to the logged in user
        if user_id = session[:user_id]
            @current_user ||= User.find_by( id: user_id)

        # if the user is NOT logged in (meaning no temporary session)
        # then we check to see if there is a signed cookie on the site
        # that was used to remember the user 
        # if there is, then we log in the user and set them to the 
        # current user
        elsif user_id = cookies.signed[:user_id]
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    # Remembers a user in a persistent session. 
    def remember(user)
        user.remember
        # encrypting the user id cookie
        cookies.permanent.signed[:user_id] = user.id

        # creates the token with the 20 year expiration
        # names the cookie remember token 
        cookies.permanent[:remember_token] = user.remember_token
    end

    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # Redirects to stored locaiton (or to the default).
    def redirect_back_or(default)
        redirect_to(session[:forwarding_url] || default)
        session.delete(:forwarding_url)
    end
    
    def store_location
        session[:forwarding_url] = request.original_url if request.get?
    end
end
