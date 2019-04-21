# frozen_string_literal: true

class TwoFactorSetupController < ApplicationController
  include Wicked::Wizard

  steps :show_qr, :confirm_code

  def show
    @user = User.find(params[:user_id])
    @token = TwoFactorToken.from_user(current_user)
    if @token.verified?
      alert = { 'class' => 'info', 'message' => 'You have already successfully setup two-factor authentication.' }
      flash[:alert] = alert
      redirect_to user_path(@user) and return
    end
    case step
    when :show_qr
      @qr = RQRCode::QRCode.new(@token.provisioning_uri, size: 12, level: :h)
    when :confirm_code
      code = params[:totp] || ''
      result = @token.verify(code)
      if result
        session[:two_factor_auth] = result
        alert = { 'class' => 'success', 'message' => 'Two-factor authentication successfully setup.' }
        flash[:alert] = alert
        redirect_to user_path(@user) and return
      else
        alert = { 'class' => 'warning', 'message' => 'Invalid two-factor authentication code.' }
        flash[:alert] = alert
        jump_to previous_step
      end
    end
    render_wizard
  end
end
