class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  helper_method :user_signed_in?

  private

    # Finds the User with the ID that is stored in the session.
    # Logging in sets this session value and logging out removes it.
    def current_user
      begin
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      rescue Exception => e
        nil
      end
    end

    # True if the user is signed in, false otherwise.
    def user_signed_in?
      return true if current_user
    end

    # Helper to block access to models for which the user is not authorised
    def check_user(user)
      unless current_user == user
        alert = { 'class' => 'danger', 'message' => 'Access denied.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'current_user not equal to user'}, status: :forbidden
      end
    end

    # Make sure the user is logged in
    def authenticate_user!
      if !current_user
        alert = { 'class' => 'danger', 'message' => 'You need to login for access to this page.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'not logged in'}, status: :unauthorized
      end
    end

end
