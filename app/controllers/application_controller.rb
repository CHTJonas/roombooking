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

    # Returns the objects used to store the client to the Camdram API.
    def camdram
      @camdram ||= Camdram::Client.new do |config|
        config.api_token = current_camdram_token.token
        config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
      end
    end

    # True if the user is signed in, false otherwise.
    def user_signed_in?
      return true if current_user && current_camdram_token
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

    # Method to ensure the user is logged in with a valid Camdram API token.
    def authenticate_user!
      if !current_user || !current_camdram_token
        invalidate_session
        alert = { 'class' => 'danger', 'message' => 'You need to login for access to this page.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'not logged in'}, status: :unauthorized and return
      end
      if current_camdram_token.expired?
        invalidate_session
        alert = { 'class' => 'warning', 'message' => 'Your session has expired. You must login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'camdram token expired'}
      end
    end

    # Method to simulate a user logoff.
    def invalidate_session
      # This removes the user_id session value
      @current_user = session[:user_id] = nil
      # This removes the camdram_token session value
      @camdram_token = session[:camdram_token_id] = nil
    end

end
