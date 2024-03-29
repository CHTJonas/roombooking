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
      log_abuse "#{user.to_log_s} attempted to login but their account is blocked"
      Roombooking::InfoCounter.poke('Unsuccessful logins since boot')
      alert = { 'class' => 'danger', 'message' => 'You have been temporarily blocked. Please try again later.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: { reason: 'user blocked' }, status: :forbidden
    elsif user.validated_at.nil?
      log_abuse "#{user.to_log_s} attempted to login but their account has not been validated yet"
      Roombooking::InfoCounter.poke('Unsuccessful logins since boot')
      alert = { 'class' => 'warning', 'message' => 'Please check your emails for the link to validate your account.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: { reason: 'user not validated' }, status: :forbidden
    else
      camdram_token = CamdramToken.from_omniauth_and_user(auth, user)
      sesh = Session.from_user_and_request(user, request)
      log_abuse "#{user.to_log_s} successfully logged in with session ID #{sesh.id} and Camdram token ID #{camdram_token.id}"
      Roombooking::InfoCounter.poke('Successful logins since boot')
      session[:sid] = sesh.id
      session[:uid] = user.id
      alert = { 'class' => 'success', 'message' => 'You have successfully logged in.' }
      flash[:alert] = alert
      redirect_to request.env['omniauth.origin'] || root_url
    end
  end

  # Handle user logouts.
  def destroy
    if user_logged_in?
      log_abuse "#{login_user.to_log_s} successfully logged out of their session with ID #{current_session.id}"
      Roombooking::InfoCounter.poke('Logouts since boot')
      invalidate_session
      alert = { 'class' => 'success', 'message' => 'You have successfully logged out.' }
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
      Roombooking::InfoCounter.poke('Auth errors since boot')
      alert = { 'class' => 'danger', 'message' => "Authentication error. Please contact support and quote the following error: #{message.humanize}." }
      flash[:alert] = alert
      render 'layouts/blank', locals: { reason: 'oauth2 failure' }, status: :internal_server_error
    end
  end
end
