# frozen_string_literal: true

class UserPermissionRefreshJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    User.find_each do |user|
      user.refresh_permissions! if user.latest_camdram_token.present?
    end
  end
end
