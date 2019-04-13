# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@adctheatre.com'
  layout 'mailer'
end
