class ContactFormMailer < ApplicationMailer
  default to: 'production@adctheatre.com'

  # Sends an email to ADC Management.
  def send_to_management(from, subject, message)
    if from.present? && subject.present? && message.present?
      @message = message
      mail(reply_to: from, subject: subject)
    else
      raise Roombooking::InvalidStateError, 'From, subject or message fields were not present'
    end
  end
end
