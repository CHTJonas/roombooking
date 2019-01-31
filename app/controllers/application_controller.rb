class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :check_browser_version
  before_action :check_user!
  before_action :set_paper_trail_whodunnit
  helper_method :current_user
  helper_method :impersonator
  helper_method :user_logged_in?
  helper_method :user_is_admin?
  helper_method :user_is_imposter?

  # Record this information when auditing models.
  def info_for_paper_trail
    {
      ip: request.remote_ip,
      user_agent: request.user_agent,
      session: current_session.try(:id)
    }
  end

  # Render a nice page when the user browses to a URL that doesn't route.
  def route_not_found
    render_404
  end

  # Render a nice page when the user attempts to view a record that doesn't exist.
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_404
  end

  def render_404
    alert = { 'class' => 'dark', 'message' => "Sorry! The page you're looking for either doesn't exist or you don't have permission to view it." }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: {reason: '404 not found'}, status: :not_found
  end

  # Rescue exceptions raised by user access violations from CanCan.
  rescue_from CanCan::AccessDenied do |exception|
    if user_logged_in?
      log_abuse "Blocked access to #{request.fullpath} by #{current_user.name.possessive} session with id #{current_session.id} as the CanCan authorisation check failed"
      alert = { 'class' => 'danger', 'message' => 'Access denied.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: "cancan access denied: #{exception.message}"}, status: :forbidden
    else
      log_abuse "Blocked access to #{request.fullpath} as no valid login session was present"
      alert = { 'class' => 'danger', 'message' => 'You need to login to access this page.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: 'not logged in'}, status: :unauthorized
    end
  end

  # Recue exceptions raised due to cross-site request forgery.
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    log_abuse "Possible CSRF attack detected at #{request.fullpath} by #{current_user.try(:name).try(:possessive) || 'anonymous user'} session with id #{current_session.try(:id) || 'none'}"
    invalidate_session
    alert = { 'class' => 'danger', 'message' => "Cross-site request forgery detected! If you are seeing this message, try clearing your browser's cache/cookies and then try again." }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: {reason: "CSRF detected: #{exception.message}"}, status: :forbidden
  end

  rescue_from Roombooking::CamdramAPI::CamdramError do |exception|
    alert = { 'class' => 'danger', 'message' => %{
Sorry, but an error occurred when making a request to the Camdram API!
This is probably a temporary error - try refreshing the page after a minute or two.
Errors are tracked automatically but do get in touch if you continue having problems.} }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: {reason: "camdram error: #{exception.message}"}, status: :internal_server_error
  end

  # Finds the Session model object with the ID that is stored in the Rails
  # session store. Logging in sets this session value and logging out
  # removes it.
  def current_session
    begin
      @current_session ||= Session
        .eager_load(user: :latest_camdram_token)
        .find(session[:sesh_id]) if session[:sesh_id]
    rescue Exception => e
      nil
    end
  end

  # Returns the User associated with the current session.
  def current_user
    @current_user ||= current_session.try(:user)
  end

  # Returns the User who is impersonating the User returned by current_user.
  def impersonator
    begin
      @impersonator ||= User.find(session[:impersonator_id]) if session[:impersonator_id]
    rescue Exception => e
      nil
    end
  end

  # Returns the CamdramToken associated with the current user.
  def current_camdram_token
    @current_camdram_token ||= current_user.try(:latest_camdram_token)
  end

  # True if the user is signed in, false otherwise.
  def user_logged_in?
    current_user.present?
  end

  # True if the user is a site administrator, false otherwise.
  def user_is_admin?
    user_logged_in? && current_user.admin?
  end

  # True if the user is being impersonated, false otherwise.
  def user_is_imposter?
    user_logged_in? && impersonator.present?
  end

  # Method to ensure a logged in user has a valid Camdram API token and is
  # not blocked.
  def check_user!
    if user_logged_in?
      if current_user.blocked?
        log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as their account was blocked"
        invalidate_session
        alert = { 'class' => 'danger', 'message' => 'Your account has been blocked by an administrator. Please try again later.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'user blocked'}, status: :unauthorized and return
      end
      if current_session.invalidated?
        log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as it was invalidated"
        invalidate_session
        alert = { 'class' => 'warning', 'message' => 'Your session has been invalidated by yourself or an administrator. Please login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'session invalidated'}, status: :unauthorized and return
      end
      if current_session.expired?
        log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as it had expired"
        invalidate_session
        alert = { 'class' => 'warning', 'message' => 'Your session has expired. Please login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'session expired'}, status: :unauthorized and return
      end
      unless current_camdram_token.present? || user_is_imposter?
        # The user is logged in and not an imposter, but we can't find a
        # Camdram API token for them. Maybe it was purged from the database?
        # Maybe there was a session issue?
        log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as no current camdram token was found"
        invalidate_session
        alert = { 'class' => 'danger', 'message' => 'A Camdram OAuth token error has occured. Please logout and then login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'camdram token not present'}, status: :internal_server_error and return
      end
      if current_camdram_token.try(:expired?)
        current_camdram_token.refresh
      end
    end
  end

  # Used by certain controllers/methods which specify this as their
  # before_action to ensures the user is an administrator.
  def must_be_admin!
    unless user_is_admin?
      log_abuse "Blocked access to #{request.fullpath} by #{current_user.try(:name).try(:possessive) || 'anonymous user'} session with id #{current_session.try(:id) || 'none'} as they are not an administrator"
      alert = { 'class' => 'danger', 'message' => "Acess denied — you don't appear to be an administrator!" }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: 'user not admin'}, status: :forbidden and return
    end
  end

  # Method to simulate/force a user logoff.
  def invalidate_session
    reset_session
    @current_session = nil
    @current_user = nil
    @current_camdram_token = nil
  end

  def log_abuse(str)
    str << " : [#{request.remote_ip} - #{request.user_agent}]"
    Yell['abuse'].info(str)
  end

  # Add extra context to any Sentry error reports.
  def set_raven_context
    Raven.user_context(id: current_user.try(:id), name: current_user.try(:name), email: current_user.try(:email))
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    Raven.tags_context(program: sentry_program_context)
  end

  # Differentiate between application and worker errors in Sentry reporting.
  def sentry_program_context
    if Rails.const_defined? 'Server'
      'rails-server'
    elsif Rails.const_defined? 'Console'
      'rails-console'
    elsif Sidekiq.server?
      'sidekiq-worker'
    end
  end

  # Make sure the user is using a modern browser.
  def check_browser_version
    unless request.format != :html || browser.modern?
      alert = { 'class' => 'danger', 'message' => "You seem to be using a very outdated web browser! Unfortunately you'll need to update your system in order to use Room Booking." }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: "outdated browser"}, status: :ok
    end
  end

  def peek_enabled?
    current_user.try(:sysadmin?) || Rails.env.development?
  end
end
