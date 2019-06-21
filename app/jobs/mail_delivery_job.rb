# frozen_string_literal: true

class MailDeliveryJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_mail'
  sidekiq_throttle threshold: { limit: 60, period: 1.hour }

  def perform(mailer, method, *args)
    if mailer.present? && method.present?
      klass = mailer.constantize
      klass.send(method, *args).deliver_now
    else
      headers = args.first
      ActionMailer::Base.mail(
        from: 'roombooking@adctheatre.com',
        to: headers['to'],
        reply_to: headers['from'],
        subject: headers['subject'],
        body: headers['body']
      ).deliver_now
    end
  end
end
