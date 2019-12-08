# frozen_string_literal: true

class ShowExpiryJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    CamdramShow.where(dormant: false).find_each do |show|
      venue_ids = CamdramVenue.all.map(&:camdram_id)
      performances = show.camdram_object.performances.select do |p|
        p.venue.present? && venue_ids.include?(p.venue.id)
      end
      last_performance = performances.sort { |p1, p2| p1.end_at - p2.end_at }.last
      if DateTime.now > last_performance.end_at
        show.update(dormant: true)
      end
    end
  end
end
