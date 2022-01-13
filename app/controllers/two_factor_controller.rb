# frozen_string_literal: true

class TwoFactorController < ApplicationController
  skip_before_action :handle_2fa!

  def new
    if two_factor_authenticated?
      redirect_to params[:origin] || root_url
    else
      render 'sessions/two_factor'
    end
  end

  def create
    url = params[:origin] || root_url
    redirect_to url and return if two_factor_authenticated?

    code = params[:totp]
    token = current_user.two_factor_token
    auth = token.verify(code)
    if auth
      session[:two_factor_auth] = auth
      log_abuse "#{current_user.to_log_s} successfully completed two-factor authentication"
      Roombooking::InfoCounter.poke('Successful 2FAs since boot')
      alert = { 'class' => 'success', 'message' => 'You have successfully logged in.' }
      flash[:alert] = alert
      redirect_to url
    else
      log_abuse "#{current_user.to_log_s} attempted two-factor authentication, but failed"
      Roombooking::InfoCounter.poke('Unsuccessful 2FAs since boot')
      alert = { 'class' => 'warning', 'message' => 'Invalid two-factor authentication code.' }
      flash.now[:alert] = alert
      render 'sessions/two_factor'
    end
  end
end
