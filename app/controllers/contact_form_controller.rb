class ContactFormController < ApplicationController
  def new
    @email = ContactFormSubmission.new
    render :form
  end

  def create
    @email = ContactFormSubmission.new(email_params)
    if verify_recaptcha(model: @email) && @email.valid?
      @email.send!
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
    params.require(:contact_form_entry).permit(:from, :subject, :message)
  end
end
