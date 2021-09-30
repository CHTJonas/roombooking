# frozen_string_literal: true

class CamdramEntityCacheWarmupJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 4 }

  def perform(global_id)
    camdram_entity = GlobalID::Locator.locate global_id
    Roombooking::CamdramApi.with_retry do
      camdram_entity.response_cache_keys.each do |key|
        Rails.cache.delete(key)
      end
      camdram_entity.clear_camdram_object!
      camdram_entity.camdram_object
    rescue Camdram::Error::GenericException
      # NOOP
    end
  end
end
