# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :check_browser_version
  before_action :check_user!
  before_action :set_paper_trail_whodunnit
  helper_method :current_user
  helper_method :true_user
  helper_method :user_logged_in?
  helper_method :user_is_admin?
  helper_method :user_is_imposter?

  # Set a custom header containing the application version.
  def render(*args)
    super.tap do
      response.headers['X-Roombooking-Version'] = Roombooking::VERSION
      response.headers['X-Camdram-Client-Version'] = Camdram::VERSION
    end
  end

  def render_404
    alert = { 'class' => 'dark', 'message' => "Sorry, but the page you're looking for doesn't exist!" }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: {reason: '404 not found'}, status: :not_found, formats: :html and return
  end

  def render_504
    render file: Rails.root.join('public', '504.html'), layout: false and return
  end

  # Render a nice page when the user browses to a URL that doesn't route.
  def route_not_found
    render_404
  end

  # Render a nice(ish) page when a request times out.
  rescue_from Rack::Timeout::RequestTimeoutException do |exception|
    Raven.capture_exception(exception)
    render_504
  end

  # Render a nice page when the user attempts to view a record that doesn't exist.
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_404
  end

  # Render a nice page when the user requests a format that isn't recognised.
  rescue_from ActionController::UnknownFormat do
    render_404
  end

  # Recue exceptions raised due to cross-site request forgery.
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    log_abuse "Possible CSRF attack detected at #{request.fullpath} by #{current_user.try(:name).try(:possessive) || 'anonymous user'} session with id #{current_session.try(:id) || 'none'}"
    invalidate_session
    alert = { 'class' => 'danger', 'message' => "Cross-site request forgery detected! If you are seeing this message, try clearing your browser's cache/cookies and then try again." }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: {reason: "CSRF detected: #{exception.message}"}, status: :forbidden, formats: :html
  end

  # Rescue exceptions raised by user access violations from CanCan.
  rescue_from CanCan::AccessDenied do |exception|
    if user_logged_in?
      log_abuse "Blocked access to #{request.fullpath} by #{current_user.name.possessive} session with id #{current_session.id} as the CanCan authorisation check failed"
      alert = { 'class' => 'danger', 'message' => "Sorry, but you don't have permission to access this page!" }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: "cancan access denied: #{exception.message}"}, status: :forbidden
    else
      log_abuse "Blocked access to #{request.fullpath} as no valid login session was present"
      alert = { 'class' => 'danger', 'message' => 'Sorry, but you need to login to access this page!' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: 'not logged in'}, status: :unauthorized
    end
  end

  rescue_from Roombooking::CamdramAPI::CamdramError do |exception|
    Raven.capture_exception(exception)
    alert = { 'class' => 'danger', 'message' => "Sorry, but an error occurred when making a request to the Camdram API! "\
      "This is probably a temporary error — try refreshing the page after a minute or two. "\
      "Errors are tracked automatically but please contact Theatre Management if you continue to experience problems." }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: {reason: "camdram error: #{exception.message}"}, status: :internal_server_error, formats: :html
  end

  # Returns the current session.
  def current_session
    begin
      @current_session ||= Session
        .eager_load(user: :latest_camdram_token)
        .find(session[:sesh_id]) if session[:sesh_id]
    rescue Exception => e
      nil
    end
  end

  # Returns the user associated with the current session.
  def current_user
    @current_user ||= current_session.try(:user)
  end

  # Returns the true user if that user is impersonating another, or nil otherwise.
  def true_user
    begin
      @true_user ||= User.find(session[:true_user_id]) if session[:true_user_id]
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
    user_logged_in? && true_user.present?
  end

  # Ensure that a user has a valid session, account and Camdram API token.
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
      if user_is_imposter?
        return
      end
      unless current_camdram_token.present?
        # The user is logged in and not an imposter, but we can't find a
        # Camdram API token for them. Maybe it was purged from the database?
        log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as no current Camdram token was found"
        invalidate_session
        alert = { 'class' => 'danger', 'message' => 'A Camdram OAuth token error has occured. Please logout and then login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'camdram token not present'}, status: :internal_server_error and return
      end
      if current_camdram_token.expired?
        if current_camdram_token.refreshable?
          current_camdram_token.refresh
        else
          log_abuse "Forced logout of #{current_user.name.possessive} session with id #{current_session.id} as the Camdram token was expired and couldn't be refreshed"
          invalidate_session
          alert = { 'class' => 'warning', 'message' => 'Your session has expired. Please login again.' }
          flash.now[:alert] = alert
          render 'layouts/blank', locals: {reason: 'unrefreshable expired camdram token'}, status: :unauthorized and return
        end
      end
    end
  end

  # Used by certain controllers to ensures the user is an administrator.
  def must_be_admin!
    raise CanCan::AccessDenied, 'user is not an administrator' unless user_is_admin?
  end

  # Method to simulate/force a user logoff.
  def invalidate_session
    current_session.try(:invalidate!)
    reset_session
    @current_session = nil
    @current_user = nil
    @current_camdram_token = nil
  end

  def log_abuse(str)
    str += " : [#{request.remote_ip} - #{request.user_agent}]"
    Yell['abuse'].info(str)
  end

  # Add extra context to any Sentry error reports.
  def set_raven_context
    Raven.user_context(sentry_user_context)
    Raven.tags_context(sentry_tags_context)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  # Params to send as user context along with Sentry errors.
  def sentry_user_context
    {
      id: current_user.try(:id),
      name: current_user.try(:name),
      email: current_user.try(:email)
    }
  end

  # Params to send as tag context along with Sentry errors.
  def sentry_tags_context
    {
      program: sentry_program_context,
      camdram_version: Camdram::VERSION
    }
  end

  # Differentiate between application and worker errors in Sentry reporting.
  def sentry_program_context
    if Rails.const_defined? 'Console'
      'rails-console'
    elsif Sidekiq.server?
      'sidekiq-worker'
    else
      'rails-server'
    end
  end

  # Record this information when auditing models.
  def info_for_paper_trail
    {
      ip: request.remote_ip,
      user_agent: request.user_agent,
      session: current_session.try(:id)
    }
  end

  # Make sure the user is using a modern browser.
  def check_browser_version
    if request.format == :html && (browser.ie? || !browser.modern?)
      alert = { 'class' => 'danger', 'message' => "You seem to be using a very outdated web browser! Unfortunately you'll need to update your system in order to use Room Booking." }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: "outdated browser"}, status: :ok
    end
  end

  # Enable development bar for sysadmins, or everyone in development.
  def peek_enabled?
    current_user.try(:sysadmin?) || Rails.env.development?
  end
end
