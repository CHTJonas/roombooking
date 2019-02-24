module Bookings
  class NewBookingService < BookingService
    def perform
      @booking = Booking.new(booking_params)
      @booking.approved = @user.admin? || ApplicationSetting.instance.auto_approve_bookings?
      @booking.user = @user
      populate_camdram_entities
      setup_booking_purpose
      raise NotAuthorisedOnCamdramException.new(@booking) unless booking_authorised_against_camdram?
    end
  end
end
