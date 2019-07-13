# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'roombooking@adctheatre.com'
  layout 'mailer'

  # Overrides the mail method to log outgoing emails.
  def mail(*args)
    msg = super
    Email.create_from_message(msg)
    msg
  end
end
