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

  # Allow emails to be delivered asynchronously using Sidekiq.
  def self.deliver_async(method, *args)
    mailer_klass = self.to_s
    MailDeliveryJob.perform_async(mailer_klass, method, *args)
  end
end
