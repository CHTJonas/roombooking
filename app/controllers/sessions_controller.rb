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
    alert = { 'class' => 'success', 'message' => auth['credentials'].inspect }
    flash[:alert] = alert
    redirect_to root_url
  end

  def destroy
    # This removes the user_id session value
    @current_user = session[:user_id] = nil
    alert = { 'class' => 'success', 'message' => 'You have successfully logged out.' }
    flash[:alert] = alert
    redirect_to root_url
  end

  def failure
    # Handle OAuth errors
    alert = { 'class' => 'danger', 'message' => "Authentication error. Please contact support and quote the following error: #{params[:message].humanize}" }
    flash[:alert] = alert
    redirect_to root_url
  end

end
