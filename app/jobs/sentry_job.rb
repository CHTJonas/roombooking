# frozen_string_literal: true

class SentryJob
  include Sidekiq::Worker
  sidekiq_options queue: 'roombooking_jobs'

  def perform(event)
    Raven.send_event(event)
  end
end
