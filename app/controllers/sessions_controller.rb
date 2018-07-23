class SessionsController < ApplicationController

  def new
    redirect_to '/auth/camdram'
  end

  def create
    auth = request.env["omniauth.auth"]
    # Find the user if they exist or create if they don't.
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    # Save the user ID in the session so it can be used for subsequent requests.
    session[:user_id] = user.id
    message = { class: 'success', message: auth['credentials'].inspect}
    redirect_to root_url, flash: { message: message }
  end

  def destroy
    # This removes the user_id session value
    @current_user = session[:user_id] = nil
    message = { class: 'success', message: 'You have successfully logged out.' }
    redirect_to root_url, flash: { message: message }
  end

  def failure
    # Handle OAuth errors
    message = { class: 'danger', message: 'Authentication error. Please contact support and quote the following error: #{params[:message].humanize}' }
    redirect_to root_url, flash: { message: message }
  end

end
