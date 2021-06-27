# frozen_string_literal: true

class SentryJob
  include Sidekiq::Worker

  sidekiq_options queue: 'roombooking_exceptions', retry: 0

  def perform(event, hint)
    Sentry.send_event(event, hint)
  end
end
