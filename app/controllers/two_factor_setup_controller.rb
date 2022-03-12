# frozen_string_literal: true

class TwoFactorSetupController < ApplicationController
  before_action :setup

  def show
    @qr = RQRCode::QRCode.new(@token.provisioning_uri, size: 12, level: :h)
  end

  def validate
    code = params[:totp] || ''
    result = @token.verify(code)
    if result
      session[:tfa] = result
      alert = { 'class' => 'success', 'message' => 'Two-factor authentication successfully setup.' }
      flash[:alert] = alert
      redirect_to user_path(@user) and return
    else
      alert = { 'class' => 'warning', 'message' => 'Invalid two-factor authentication code.' }
      flash[:alert] = alert
      jump_to previous_step
    end
  end

  private

  def setup
    @user = User.find(params[:id])
    @token = TwoFactorToken.from_user(current_user)
    if @token.verified?
      alert = { 'class' => 'info', 'message' => 'You have already successfully setup two-factor authentication.' }
      flash[:alert] = alert
      redirect_to user_path(@user) and return
    end
  end
end
