class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?

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

    # True if the user is accessing their own user page, false otherwise.
    def correct_user?
      begin
        @user = User.find(params[:id])
      rescue Exception => e
        nil
      end
      unless current_user == @user
        options = { class: 'danger', message: 'Access denied' }
        flash[:alert] = Roombooking::Alert.new(options)
        redirect_to root_url
      end
    end

    # Make sure the user is logged in
    def authenticate_user!
      if !current_user
        options = { class: 'danger', message: 'You need to login for access to this page.' }
        flash[:alert] = Roombooking::Alert.new(options)
        redirect_to root_url
      end
    end

end
