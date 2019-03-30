# frozen_string_literal: true

class SessionsController < ApplicationController

  def new
    # Issue a new session identifier to protect against fixation
    reset_session
    redirect_to '/auth/camdram'
  end

  def create
    auth = request.env['omniauth.auth']
    # Find the user if they exist or create if they don't.
    user = ProviderAccount.find_by(provider: auth['provider'], uid: auth['uid'].to_s).try(:user) || User.from_provider(auth)
    # Issue a new session identifier to protect against fixation
    reset_session
    # Log the event and render/redirect.
    if user.blocked?
      log_abuse "#{user.name} attempted to login but their account is blocked"
      user = nil
      alert = { 'class' => 'danger', 'message' => 'You have been temporarily blocked. Please try again later.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: 'user blocked'}, status: :forbidden
    else
      # Create a record to store the Camdram API token.
      camdram_token = CamdramToken.create_with_credentials(auth['credentials'], user)

      # Create a record to store the session.
      sesh = Session.create(user: user, expires_at: DateTime.now + 60.days,
        login_at: DateTime.now, ip: request.remote_ip, user_agent: request.user_agent)

      # Make a note of the login to track any abuse.
      log_abuse "#{user.name} successfully logged in with session #{sesh.id} and camdram token #{camdram_token.id}"

      # Save the session object ID in the Rails session store so that it can
      # be used for subsequent requests.
      session[:sesh_id] = sesh.id

      alert = { 'class' => 'success', 'message' => 'You have successfully logged in.' }
      flash[:alert] = alert
      redirect_to root_url
    end
  end

  def destroy
    if user_logged_in?
      log_abuse "#{current_user.name.capitalize} successfully logged out of their session with id #{current_session.id}"
      current_session.invalidate!
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
      alert = { 'class' => 'warning', 'message' => "Login gracefully declined." }
      flash[:alert] = alert
      redirect_to root_url
    else
      log_abuse "A login authentication system error occurred: #{message.humanize}"
      alert = { 'class' => 'danger', 'message' => "Authentication error. Please contact support and quote the following error: #{message.humanize}." }
      flash[:alert] = alert
      render 'layouts/blank', locals: {reason: 'oauth2 failure'}, status: :internal_server_error
    end
  end

end
