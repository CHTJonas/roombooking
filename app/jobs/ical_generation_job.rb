# frozen_string_literal: true

class IcalGenerationJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }, threshold: { limit: 5, period: 10.minutes }

  def perform
    service = IcalGenerationService.new(Booking.find_each(batch_size: 10), 'rooms')
    service.perform(refresh_cache: true)
    Room.find_each(batch_size: 10) do |room|
      service = IcalGenerationService.new(room.bookings.find_each(batch_size: 10), room.cache_key)
      service.perform(refresh_cache: true)
    end
  end
end
