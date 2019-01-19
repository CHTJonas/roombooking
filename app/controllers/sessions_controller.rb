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
      LogEvent.log(user, 'failure', 'User login', 'web', request.remote_ip, request.user_agent)
      user = nil
      alert = { 'class' => 'danger', 'message' => 'You have been temporarily blocked. Please try again later.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: 'user blocked'}, status: :forbidden
    else
      LogEvent.log(user, 'success', 'User login', 'web', request.remote_ip, request.user_agent)

      # Create an object to store the Camdram API token.
      camdram_token = CamdramToken.create_with_credentials(auth['credentials'], user)

      # Create an object to represent the session.
      sesh = Session.create(user: user,
                            expires_at: Time.at(camdram_token.expires_at) + 1.hour,
                            login_at: DateTime.now,
                            ip: request.remote_ip,
                            user_agent: request.user_agent)

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
      LogEvent.log(current_user, 'success', 'User logout', 'web', request.remote_ip, request.user_agent)
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
    else
      alert = { 'class' => 'danger', 'message' => "Authentication error. Please contact support and quote the following error: #{message.humanize}" }
      flash[:alert] = alert
      redirect_to root_url
    end
  end

end
