module Bookings
  class UpdateBookingService < BookingService
    def perform
      @booking = Booking.find(@params[:id])
      @booking.attributes = booking_params
      populate_data_from_camdram
      setup_booking_purpose
      raise NotAuthorisedOnCamdramException.new(@booking, @shows, @societies) unless booking_authorise_against_camdram?
    end
  end
end
