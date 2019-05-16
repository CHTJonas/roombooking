# frozen_string_literal: true

module Bookings
  class NewBookingService < BookingService
    def perform
      @booking = Booking.new(booking_params)
      @booking.user = @user
      populate_camdram_entities
      setup_booking_purpose
      raise NotAuthorisedOnCamdramException.new(@booking) unless booking_authorised_against_camdram?
      @booking
    end
  end
end
