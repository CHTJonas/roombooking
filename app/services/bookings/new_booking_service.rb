module Bookings
  class NewBookingService < BookingService
    def perform
      @booking = Booking.new(booking_params)
      @booking.approved = @user.admin? || ApplicationSetting.instance.auto_approve_bookings?
      @booking.user = @user
      populate_data_from_camdram
      setup_booking_purpose
      raise NotAuthorisedOnCamdramException.new(@booking, @shows, @societies) unless booking_authorise_against_camdram?
    end
  end
end
