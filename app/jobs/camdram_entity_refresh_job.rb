# frozen_string_literal: true

class CamdramEntityRefreshJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    CamdramShow.find_each(batch_size: 10) { |e| refresh.call(e) }
    CamdramSociety.find_each(batch_size: 10) { |e| refresh.call(e) }
  end

  def refresh
    @refresh ||= Proc.new do |camdram_entity|
      begin
        retries ||= 0
        camdram_entity.name(true)
      rescue Roombooking::CamdramAPI::CamdramError
        if (retries += 1) < 5
          sleep 5 # Sleep for a short while in case Camdram is overloaded.
          retry
        end
      end
      sleep 1 # Avoid hitting Camdram with requests too hard.
    end
  end
end
