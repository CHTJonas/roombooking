# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :increment_request_counter
  before_action :set_response_headers
  before_action :set_sentry!
  before_action :check_browser_version
  include Roombooking::Auth
  before_action :set_paper_trail_whodunnit

  def render_404
    alert = { 'class' => 'dark', 'message' => "Sorry, but the page you're looking for doesn't exist!" }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: { reason: '404 not found' }, status: :not_found, formats: :html and return
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
    Sentry.capture_exception(exception)
    render_504
  end

  # Render a nice page when the user attempts to view a record that doesn't exist.
  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render_404
  end

  # Render a nice page when the user requests a format that isn't recognised.
  rescue_from ActionController::UnknownFormat do
    render_404
  end

  # Recue exceptions raised due to cross-site request forgery.
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    log_abuse "Possible CSRF attack detected at #{request.fullpath} by #{current_user.try(:to_log_s) || 'anonymous user'} session with session ID #{current_session.try(:id) || 'none'}"
    invalidate_session
    alert = { 'class' => 'danger', 'message' => "Cross-site request forgery detected! If you are seeing this message, try clearing your browser's cache/cookies and then try again." }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: { reason: "CSRF detected: #{exception.message}" }, status: :forbidden, formats: :html
  end

  # Rescue exceptions raised by user access violations from CanCan.
  rescue_from CanCan::AccessDenied do |exception|
    if user_logged_in?
      log_abuse "Blocked access to #{request.fullpath} by #{current_user.to_log_s} with session ID #{current_session.id} as the CanCan authorisation check failed"
      alert = { 'class' => 'danger', 'message' => "Sorry, but you don't have permission to access this page!" }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: { reason: "cancan access denied: #{exception.message}" }, status: :forbidden
    else
      log_abuse "Blocked access to #{request.fullpath} as no valid login session was present"
      alert = { 'class' => 'danger', 'message' => 'Sorry, but you need to login to access this page!' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: { reason: 'not logged in' }, status: :unauthorized
    end
  end

  rescue_from Camdram::Error::GenericException do |exception|
    Sentry.capture_exception(exception)
    alert = { 'class' => 'danger', 'message' => 'Sorry, but an error occurred when making a request to the Camdram API! Errors are tracked automatically but please contact Theatre Management if you continue to experience problems.' }
    flash.now[:alert] = alert
    render 'layouts/blank', locals: { reason: "camdram error: #{exception.message}" }, status: :internal_server_error, formats: :html
  end

  def log_abuse(str)
    str += " : [#{request.remote_ip} - #{request.user_agent}]"
    Yell['abuse'].info(str)
  end

  def increment_request_counter
    Roombooking::InfoCounter.poke('Requests since boot')
  end

  def set_response_headers
    response.headers['X-Powered-By'] = 'https://github.com/CHTJonas/roombooking'
  end

  # Add extra context to any Sentry error reports.
  def set_sentry!
    Sentry.set_user(sentry_user_context)
    Sentry.set_tags(sentry_tags_context)
    Sentry.set_extras(sentry_extras_context)
  end

  # User context to send to Sentry.
  def sentry_user_context
    {
      id: current_user.try(:id),
      name: current_user.try(:name),
      email: current_user.try(:email)
    }
  end

  # Tags context to send to Sentry.
  def sentry_tags_context
    {
      program: sentry_program_context,
      camdram_version: Camdram::Version.to_s
    }
  end

  # Extras context to send to Sentry.
  def sentry_extras_context
    {
      params: params.to_unsafe_h,
      url: request.url
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
    if Rails.env.production? && request.format == :html && !browser_is_modern?
      alert = { 'class' => 'danger', 'message' => "You seem to be using a very outdated web browser! Unfortunately you'll need to update your system in order to use Room Booking." }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: { reason: 'outdated browser' }, status: :ok
    end
  end

  def browser_is_modern?
    [
      browser.chrome?(">= 65"),
      browser.safari?(">= 10"),
      browser.firefox?(">= 52"),
      browser.edge?(">= 15"),
      browser.opera?(">= 50"),
      browser.facebook? && browser.safari_webapp_mode? && browser.webkit_full_version.to_i >= 602,
      browser.bot?
    ].any?
  end
end
