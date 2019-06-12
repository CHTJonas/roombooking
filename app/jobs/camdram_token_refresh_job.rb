# frozen_string_literal: true

class CamdramTokenRefreshJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    User.find_each(batch_size: 10) do |user|
      # Remove all OAuth2 access tokens that can't be refreshed.
      user.camdram_tokens.dead.destroy_all
      # Attempt to refresh the last such valid token that's about to expire,
      # but skip over it if an exception is raised.
      begin
        sleep 0.7 # Avoid hitting Camdram with requests too hard.
        user.camdram_tokens.expiring_soon.last.try(:refresh)
      rescue => e
        Raven.capture_exception(e)
        next
      end
    end
  end
end
