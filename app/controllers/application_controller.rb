class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  helper_method :user_signed_in?
  helper_method :user_is_admin?

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

    # Finds the CamdramToken with the ID that is stored in the session.
    # Logging in sets this session value and logging out removes it.
    def current_camdram_token
      begin
        @camdram_token ||= CamdramToken.find(session[:camdram_token_id]) if session[:camdram_token_id]
      rescue Exception => e
        nil
      end
    end

    # True if the user is signed in, false otherwise.
    def user_signed_in?
      return true if current_user
    end

    # True if the user is a site administrator, false otherwise.
    def user_is_admin?
      return user_signed_in? && current_user.is_admin?
    end

    # Helper to block access to models for which the user is not authorised.
    def check_user(user)
      return if user_is_admin? # Admins can do anything!
      unless current_user == user
        alert = { 'class' => 'danger', 'message' => 'Access denied.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'current_user not equal to user'}, status: :forbidden
      end
    end

    # Method to make sure the user is logged in.
    def authenticate_user!
      if !current_user
        alert = { 'class' => 'danger', 'message' => 'You need to login for access to this page.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'not logged in'}, status: :unauthorized
      end
    end

end
