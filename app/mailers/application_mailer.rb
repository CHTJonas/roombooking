# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'roombooking@adctheatre.com'
  layout 'mailer'
end
