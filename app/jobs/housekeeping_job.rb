# frozen_string_literal: true

class HousekeepingJob < ApplicationJob
  concurrency 1, drop: true

  def perform(*args)
    User.find_each(batch_size: 10) do |user|
      user.camdram_token.dead.destroy_all
      # Attempt to refresh the token but skip over it if an exception is thrown
      begin
        user.camdram_token.expiring_soon.last.try(:refresh)
      rescue => e
        Raven.capture_exception(e)
        next
      end
    end
  end
end
