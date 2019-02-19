module Bookings
  class UpdateBookingService < BookingService
    def perform
      @booking = Booking.find(@params[:id])
      @booking.attributes = booking_params
      populate_data_from_camdram
      setup_booking_purpose
      data = [@booking, @shows, @societies]
      raise NotAuthorisedOnCamdramException.new(data) unless booking_authorise_against_camdram?
      data
    end
  end
end
