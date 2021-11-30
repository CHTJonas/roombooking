# frozen_string_literal: true

class UserPermissionRefreshJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    User.includes(:latest_camdram_token).find_each(batch_size: 10) do |user|
      if user.admin? || (user.latest_camdram_token.present? && !user.latest_camdram_token.expired?)
        user.refresh_permissions!
      end
    rescue StandardError => e
      Sentry.capture_exception(e)
      next
    end
  end
end
