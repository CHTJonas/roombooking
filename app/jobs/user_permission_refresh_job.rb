# frozen_string_literal: true

class UserPermissionRefreshJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    User.joins(:latest_camdram_token).includes(:latest_camdram_token).find_each do |user|
      user.refresh_permissions!
    end
  end
end
