# frozen_string_literal: true

class CamdramEntityCacheWarmupJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 4 }

  def perform(global_id)
    camdram_entity = GlobalID::Locator.locate global_id
    Roombooking::CamdramApi.with_retry do
      camdram_entity.name(refresh_cache: true)
    rescue Camdram::Error::GenericException
      # Preserve cache, do nothing.
    end
  end
end
