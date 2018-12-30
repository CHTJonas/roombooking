class SessionsController < ApplicationController

  def new
    redirect_to '/auth/camdram'
  end

  def create
    auth = request.env['omniauth.auth']
    # Find the user if they exist or create if they don't.
    user = ProviderAccount.find_by(provider: auth['provider'], uid: auth['uid'].to_s).try(:user) || User.create_with_provider(auth)
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
      # Save the user ID in the session so it can be used for subsequent requests.
      session[:user_id] = user.id
      # Create an object to store the Camdram API token.
      camdram_token = CamdramToken.create_with_credentials(auth['credentials'], user)
      # Save the Camdram API token ID in the session so it can be used for subsequent requests.
      session[:camdram_token_id] = camdram_token.id
      alert = { 'class' => 'success', 'message' => 'You have successfully logged in.' }
      flash[:alert] = alert
      redirect_to root_url
    end
  end

  def destroy
    if user_signed_in?
      LogEvent.log(current_user, 'success', 'User logout', 'web', request.remote_ip, request.user_agent)
      invalidate_session
      alert = { 'class' => 'success', 'message' => 'You have successfully logged out.' }
      flash[:alert] = alert
    end
    redirect_to root_url
  end

  def failure
    # Handle OAuth errors
    alert = { 'class' => 'danger', 'message' => "Authentication error. Please contact support and quote the following error: #{params[:message].humanize}" }
    flash[:alert] = alert
    redirect_to root_url
  end

end
