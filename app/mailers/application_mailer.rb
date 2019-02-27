# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  self.delivery_job = EmailDeliveryJob

  default from: 'roombooking@adctheatre.com'
  layout 'mailer'
end
