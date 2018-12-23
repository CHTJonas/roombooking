class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :check_user!
  helper_method :user_signed_in?
  helper_method :user_is_admin?

  # Rescue exceptions raised by user access violations from CanCan
  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      alert = { 'class' => 'danger', 'message' => 'Access denied.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: "cancan access denied: #{exception.message}"}, status: :forbidden
    else
      alert = { 'class' => 'danger', 'message' => 'You need to login for access to this page.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: 'not logged in'}, status: :unauthorized
    end
  end

  # Recue exceptions raised due to cross-site request forgery
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    invalidate_session
    alert = { 'class' => 'danger', 'message' => "Cross-site request forgery detected! If you are seeing this message, try clearing your browser's cache/cookies and then try again." }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: {reason: "CSRF detected: #{exception.message}"}, status: :forbidden
  end

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
    return true if current_user
  end

  # True if the user is a site administrator, false otherwise.
  def user_is_admin?
    return user_signed_in? && current_user.admin?
  end

  # Method to ensure a logged in user has a valid Camdram API token and is not blocked.
  def check_user!
    if user_signed_in?
      unless current_camdram_token
        # The user is logged in but we can't find a Camdram API token for them.
        # Maybe it was purged from the database? Maybe there was a session issue?
        invalidate_session
        return
      end
      if current_camdram_token.expired?
        invalidate_session
        alert = { 'class' => 'warning', 'message' => 'Your session has expired. You must login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'camdram token expired'}, status: :unauthorized and return
      end
      if current_user.blocked?
        invalidate_session
        alert = { 'class' => 'danger', 'message' => 'You have been temporarily blocked. Please try again later.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'user blocked'}, status: :unauthorized and return
      end
    end
  end

  # Method to simulate a user logoff.
  def invalidate_session
    # This removes the user_id session value
    @current_user = session[:user_id] = nil
    # This removes the camdram_token session value
    @camdram_token = session[:camdram_token_id] = nil
    # Issue a new session identifier to protect against fixation
    reset_session
  end

  def set_raven_context
    Raven.user_context(id: current_user.try(:id), name: current_user.try(:name), email: current_user.try(:email))
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

end
