class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :check_browser_version
  before_action :check_user!
  before_action :set_paper_trail_whodunnit
  helper_method :current_user
  helper_method :user_logged_in?
  helper_method :user_is_admin?

  # Record this information when auditing models
  def info_for_paper_trail
    { ip: request.remote_ip, user_agent: request.user_agent }
  end

  # Rescue exceptions raised by user access violations from CanCan
  rescue_from CanCan::AccessDenied do |exception|
    if user_logged_in?
      alert = { 'class' => 'danger', 'message' => 'Access denied.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: "cancan access denied: #{exception.message}"}, status: :forbidden
    else
      alert = { 'class' => 'danger', 'message' => 'You need to login to access this page.' }
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

  # Returns the application-wide Camdram API client from the Rails config.
  def camdram
    Rails.application.config.camdram_client_pool.checkout
  end

  # True if the user is signed in, false otherwise.
  def user_logged_in?
    !current_user.nil?
  end

  # True if the user is a site administrator, false otherwise.
  def user_is_admin?
    return user_logged_in? && current_user.admin?
  end

  # Method to ensure a logged in user has a valid Camdram API token and is not blocked.
  def check_user!
    if user_logged_in?
      unless current_camdram_token
        # The user is logged in but we can't find a Camdram API token for them.
        # Maybe it was purged from the database? Maybe there was a session issue?
        invalidate_session
        return
      end
      if current_camdram_token.expired?
        invalidate_session
        alert = { 'class' => 'warning', 'message' => 'Your session has expired. Please login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'camdram token expired'}, status: :unauthorized and return
      end
      if current_user.blocked?
        invalidate_session
        alert = { 'class' => 'danger', 'message' => 'Your account has been blocked by an administrator. Please try again later.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'user blocked'}, status: :unauthorized and return
      end
    end
  end

  # Method to simulate/force a user logoff.
  def invalidate_session
    reset_session
    @current_user = nil
    @camdram_token = nil
  end

  def set_raven_context
    Raven.user_context(id: current_user.try(:id), name: current_user.try(:name), email: current_user.try(:email))
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def check_browser_version
    unless browser.modern?
      alert = { 'class' => 'danger', 'message' => "You seem to be using a very outdated web browser! Unfortunately you'll need to update your system in order to use room booking." }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: "outdated browser"}, status: :ok
    end
  end

end
