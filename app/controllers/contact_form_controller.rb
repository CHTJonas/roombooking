class ContactFormController < ApplicationController
  def new
    @email = Email.new
    render :form
  end

  def create
    @email = Email.new(email_params)
    @email.to = 'production@adctheatre.com'
    if @email.save
      # Send email here
      alert = { 'class' => 'success', 'message' => 'Your message has been sent!' }
      flash[:alert] = alert
      redirect_to contact_path
    else
      alert = { 'class' => 'danger', 'message' => @email.errors.full_messages.first }
      flash.now[:alert] = alert
      render :form
    end
  end

  private

  def email_params
    params.require(:email).permit(:from, :subject, :body)
  end
end
