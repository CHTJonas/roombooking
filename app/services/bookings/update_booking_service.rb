# frozen_string_literal: true

module Bookings
  class UpdateBookingService < BookingService
    def perform
      @booking = Booking.find(@params[:id])
      @booking.attributes = booking_params
      populate_camdram_entities
      setup_booking_purpose
      raise NotAuthorisedOnCamdramException.new(@booking) unless booking_authorised_against_camdram?
      @booking
    end
  end
end
