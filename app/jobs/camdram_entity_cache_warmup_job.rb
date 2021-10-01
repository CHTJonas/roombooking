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
      name = camdram_entity.camdram_object.try(:name)
      if camdram_entity.instance_of?(CamdramShow) && name.present?
        camdram_entity.with_lock do
          camdram_entity.update!(memoized_name: name)
        end
      end
    rescue Camdram::Error::GenericException
      # NOOP
    end
  end
end
