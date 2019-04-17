# frozen_string_literal: true

class Auth::ConfirmationsController < Devise::ConfirmationsController
  def new
    self.resource = resource_class.new
  end

  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    if successfully_sent?(resource)
      alert = { 'class' => 'info', 'message' => "We've just sent an email to the registered address of your Camdram account. Please follow the link to verify your new account." }
      flash[:alert] = alert
      redirect_to new_session_path
    else
      alert = { 'class' => 'danger', 'message' => resource.errors.full_messages.first }
      flash.now[:alert] = alert
      render :new
    end
  end

  def show
    token = params[:confirmation_token]
    self.resource = resource_class.confirm_by_token(token)
    if resource.errors.empty?
      alert = { 'class' => 'success', 'message' => "Email address successfully verified!" }
      flash[:alert] = alert
      redirect_to new_session_path
    else
      alert = { 'class' => 'danger', 'message' => "Email verification token not recognised!" }
      flash[:alert] = alert
      redirect_to new_user_confirmation_path
    end
  end
end
