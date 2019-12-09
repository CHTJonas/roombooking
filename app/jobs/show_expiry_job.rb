# frozen_string_literal: true

class ShowExpiryJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    now = DateTime.now
    venue_ids = CamdramVenue.all.map(&:camdram_id)
    CamdramShow.where(dormant: false).find_each do |show|
      camdram_object = show.camdram_object
      next if camdram_object.nil?
      performances = camdram_object.performances.select do |p|
        p.venue.present? && venue_ids.include?(p.venue.id)
      end
      last_performance = performances.sort { |p1, p2| p1.end_at - p2.end_at }.last
      if last_performance.present? && last_performance.end_at < now
        show.update(dormant: true)
      end
    end
  end
end
