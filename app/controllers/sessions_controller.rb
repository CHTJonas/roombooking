class SessionsController < ApplicationController

  def new
    redirect_to '/auth/camdram'
  end

  def create
    auth = request.env["omniauth.auth"]
    # Find the user if they exist or create if they don't.
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    # Save the user ID in the session so it can be used subsequent requests.
    session[:user_id] = user.id
    redirect_to root_url, flash: { success: 'You have successfully logged in.' }
  end

  def destroy
    # This removes the user_id session value
    @current_user = session[:user_id] = nil
    redirect_to root_url, flash: { success: 'You have successfully logged out.' }
  end

  def failure
    # Handle OAuth errors
    redirect_to root_url, flash: { danger: "Authentication error. Please contact support and quote the following error: #{params[:message].humanize}" }
  end

end
