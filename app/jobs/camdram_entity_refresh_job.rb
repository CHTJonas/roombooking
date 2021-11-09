# frozen_string_literal: true

class CamdramEntityRefreshJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    CamdramShow.where(dormant: false).find_each(batch_size: 10).each(&:warm_cache!)
    CamdramSociety.find_each(batch_size: 10).each(&:warm_cache!)
    CamdramVenue.find_each(batch_size: 10).each(&:warm_cache!)
  end
end
