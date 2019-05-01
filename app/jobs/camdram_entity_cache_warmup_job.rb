# frozen_string_literal: true

class CamdramEntityCacheWarmupJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 4 }

  def perform(global_id)
    camdram_entity = GlobalID::Locator.locate global_id
    begin
      retries ||= 0
      camdram_entity.name(refresh_cache: true)
    rescue Roombooking::CamdramAPI::ClientError
      # Preserve cache, do nothing.
    rescue Roombooking::CamdramAPI::ServerError
      if (retries += 1) < 5
        sleep 5 # Sleep for a short while in case Camdram is overloaded.
        retry
      end
    end
  end
end
