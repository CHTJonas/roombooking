# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_sentry!
  before_action :check_browser_version
  include Roombooking::Auth
  before_action :set_paper_trail_whodunnit

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
    alert = { 'class' => 'danger', 'message' => "Sorry, but an error occurred when making a request to the Camdram API! Errors are tracked automatically but please contact Theatre Management if you continue to experience problems." }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: {reason: "camdram error: #{exception.message}"}, status: :internal_server_error, formats: :html
  end

  def log_abuse(str)
    str += " : [#{request.remote_ip} - #{request.user_agent}]"
    Yell['abuse'].info(str)
  end

  # Add extra context to any Sentry error reports.
  def set_sentry!
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
    if Rails.env.production? && request.format == :html && (browser.ie? || !browser.modern?)
      alert = { 'class' => 'danger', 'message' => "You seem to be using a very outdated web browser! Unfortunately you'll need to update your system in order to use Room Booking." }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: "outdated browser"}, status: :ok
    end
  end

  # Enable development bar for authenticated sysadmins, or everyone in development.
  def peek_enabled?
    return false
    (user_fully_authenticated? && current_user.sysadmin?) || Rails.env.development?
  end
end
