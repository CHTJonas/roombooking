# frozen_string_literal: true

class CamdramTokenRefreshJob < ApplicationJob
  concurrency 1, drop: true

  def perform(*args)
    User.find_each(batch_size: 10) do |user|
      # Remove all OAuth2 access tokens that can't be refreshed.
      user.camdram_token.dead.destroy_all
      # Attempt to refresh the last such valid token that's about to expire,
      # but skip over it if an exception is raised.
      begin
        sleep 0.7 # Avoid hitting Camdram with requests too hard.
        user.camdram_token.expiring_soon.last.try(:refresh)
      rescue => e
        Raven.capture_exception(e)
        next
      end
    end
  end
end
