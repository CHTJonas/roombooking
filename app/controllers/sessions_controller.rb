# frozen_string_literal: true

# Note that in this controller we often call reset_session to issue new
# session identifiers in order to protect against session fixation.
class SessionsController < ApplicationController
  skip_before_action :handle_2fa!

  # Displays the login instructions page.
  def new
    @referer_path = URI(request.referer).path if request.referer
    reset_session
  end

  # Handle user logins after an OAuth2 provider redirects.
  def create
    auth = request.env['omniauth.auth']
    user = User.from_omniauth(auth)
    reset_session
    if user.blocked?
      log_abuse "#{user.name} attempted to login but their account is blocked"
      alert = { 'class' => 'danger', 'message' => 'You have been temporarily blocked. Please try again later.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: { reason: 'user blocked' }, status: :forbidden
    elsif user.validated_at.nil?
      log_abuse "#{user.name} attempted to login but their account has not been validated yet"
      alert = { 'class' => 'warning', 'message' => 'Please check your emails for the link to validate your account.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: { reason: 'user not validated' }, status: :forbidden
    else
      camdram_token = CamdramToken.from_omniauth_and_user(auth, user)
      sesh = Session.from_user_and_request(user, request)
      log_abuse "#{user.name} successfully logged in with session #{sesh.id} and camdram token #{camdram_token.id}"
      session[:sesh_id] = sesh.id
      alert = { 'class' => 'success', 'message' => 'You have successfully logged in.' }
      flash[:alert] = alert
      redirect_to request.env['omniauth.origin'] || root_url
    end
  end

  # Handle user logouts.
  def destroy
    if user_logged_in?
      log_abuse "#{current_user.name.capitalize} successfully logged out of their session with id #{current_session.id}"
      invalidate_session
      alert = { 'class' => 'success', 'message' => 'You have successfully logged out.' }
      flash[:alert] = alert
    end
    redirect_to root_url
  end

  # Forces a logout everywhere the user is currently logged in by invalidating all active sessions.
  def destroy_all
    if user_logged_in?
      log_abuse "#{current_user.name.capitalize} successfully triggered a log out of all their current sessions from the session with id #{current_session.id}"
      invalidate_session
      Session.where(user: current_user, invalidated: false).map(&:invalidate!)
      alert = { 'class' => 'success', 'message' => 'You have successfully been logged out on all your devices.' }
      flash[:alert] = alert
    end
    redirect_to root_url
  end

  # Gracefully handle OAuth failures.
  def failure
    message = params[:message]
    if message == 'csrf_detected'
      raise ActionController::InvalidAuthenticityToken
    elsif message == 'access_denied'
      log_abuse 'User declined to login at Camdram prompt screen'
      alert = { 'class' => 'warning', 'message' => 'Login gracefully declined.' }
      flash[:alert] = alert
      redirect_to root_url
    else
      log_abuse "A login authentication system error occurred: #{message.humanize}"
      alert = { 'class' => 'danger', 'message' => "Authentication error. Please contact support and quote the following error: #{message.humanize}." }
      flash[:alert] = alert
      render 'layouts/blank', locals: { reason: 'oauth2 failure' }, status: :internal_server_error
    end
  end
end
