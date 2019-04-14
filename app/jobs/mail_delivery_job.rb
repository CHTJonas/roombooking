# frozen_string_literal: true

class MailDeliveryJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_mail'
  sidekiq_throttle threshold: { limit: 60, period: 1.hour }

  def perform(mailer, method, *args)
    klass = mailer.constantize
    klass.send(method, *args).deliver
  end
end
