# frozen_string_literal: true

class CamdramEntityRefreshJob
  include Sidekiq::Worker
  sidekiq_options queue: 'roombooking_jobs'

  # concurrency 1, drop: true

  def perform
    CamdramShow.find_each(batch_size: 10) { |e| refresh.call(e) }
    CamdramSociety.find_each(batch_size: 10) { |e| refresh.call(e) }
  end

  def refresh
    @refresh ||= Proc.new do |camdram_entity|
      camdram_entity.name(true)
      sleep 1 # Avoid hitting Camdram with requests too hard.
    end
  end
end
