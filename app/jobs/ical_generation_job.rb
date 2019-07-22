# frozen_string_literal: true

class IcalGenerationJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 },
    threshold: { limit: 5, period: 10.minutes }

  def perform
    service = IcalGenerationService.new(Booking.all, 'rooms')
    service.perform(refresh_cache: true)
    sleep 6
    Room.all.each do |room|
      service = IcalGenerationService.new(room.bookings, room.cache_key)
      service.perform(refresh_cache: true)
      sleep 3
    end
  end
end
