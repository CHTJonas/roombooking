# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :check_browser_version
  before_action :check_user!
  before_action :set_paper_trail_whodunnit
  helper_method :user_is_admin?
  helper_method :user_is_imposter?

  impersonates :user

  # Set a custom header containing the application version.
  def render(*args)
    super.tap do
      response.headers['X-Roombooking-Version'] = Roombooking::VERSION
      response.headers['X-Camdram-Client-Version'] = Camdram::VERSION
    end
  end

  def render_404
    alert = { 'class' => 'dark', 'message' => "Sorry! The page you're looking for either doesn't exist or you don't have permission to view it." }
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
    log_abuse "Possible CSRF attack detected at #{request.fullpath} by #{current_user.try(:name) || 'anonymous user'}"
    sign_out(current_user)
    alert = { 'class' => 'danger', 'message' => "Cross-site request forgery detected! If you are seeing this message, try clearing your browser's cache/cookies and then try again." }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: { reason: "CSRF detected: #{exception.message}" }, status: :forbidden, formats: :html
  end

  # Rescue exceptions raised by user access violations from CanCan.
  rescue_from CanCan::AccessDenied do |exception|
    log_abuse "Blocked access to #{request.fullpath} by #{current_user.try(:name) || 'anonymous user'} as they were unauthorised"
    alert = { 'class' => 'danger', 'message' => "Sorry, but you don't have permission to do that!" }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: { reason: "cancan access denied: #{exception.message}" }, status: :forbidden
  end

  # Rescue exceptions raised when making requests to the Camdram API.
  rescue_from Roombooking::CamdramAPI::CamdramError do |exception|
    Raven.capture_exception(exception)
    alert = { 'class' => 'danger', 'message' => %{
Sorry, but an error occurred when making a request to the Camdram API!
This is probably a temporary error - try refreshing the page after a minute or two.
Errors are tracked automatically but do get in touch if you continue having problems.} }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: { reason: "camdram error: #{exception.message}" }, status: :internal_server_error, formats: :html
  end

  # Returns the CamdramToken associated with the current user.
  def current_camdram_token
    @current_camdram_token ||= current_user.try(:latest_camdram_token)
  end

  # True if the user is a site administrator, false otherwise.
  def user_is_admin?
    user_signed_in? && current_user.admin?
  end

  # True if the user is being impersonated, false otherwise.
  def user_is_imposter?
    user_signed_in? && current_user != true_user
  end

  # Ensure that a user has a valid session, account and Camdram API token.
  def check_user!
    if user_signed_in?
      if current_user.blocked?
        log_abuse "Forced logout of #{current_user.name} as their account was blocked"
        sign_out(current_user)
        alert = { 'class' => 'danger', 'message' => 'Your account has been blocked by an administrator. Please try again later.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'user blocked'}, status: :unauthorized and return
      end
      if user_is_imposter?
        # Don't bother checking Camdram tokens if we're impersonating another user.
        return
      end
      unless current_camdram_token.present?
        # The user is logged in and not an imposter, but we can't find a
        # Camdram API token for them. Maybe it was purged from the database?
        log_abuse "Forced logout of #{current_user.name} as no current Camdram token was found"
        sign_out(current_user)
        alert = { 'class' => 'danger', 'message' => 'A Camdram OAuth token error has occured. Please logout and then login again.' }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'current camdram token not present'}, status: :internal_server_error and return
      end
      if current_camdram_token.expired?
        if current_camdram_token.refreshable?
          current_camdram_token.refresh
        else
          log_abuse "Forced logout of #{current_user.name} session as the current Camdram token had expired and couldn't be refreshed"
          sign_out(current_user)
          alert = { 'class' => 'warning', 'message' => 'Your session has expired. Please login again.' }
          flash.now[:alert] = alert
          render 'layouts/blank', locals: {reason: 'current camdram token expired'}, status: :unauthorized and return
        end
      end
    end
  end

  # Used by certain controllers/methods which specify this as their
  # before_action to ensures the user is an administrator.
  def must_be_admin!
    authenticate_user!
    raise CanCan::AccessDenied, 'user is not an administrator' unless user_is_admin?
  end

  # Logs the given string to the abuse.log file.
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

  # Parameters to send as tag context along with Sentry errors.
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

  # Enable development bar for sysadmins in production, or everyone in
  # development.
  def peek_enabled?
    current_user.try(:sysadmin?) || Rails.env.development?
  end
end
