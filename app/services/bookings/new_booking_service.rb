module Bookings
  class NewBookingService < BookingService
    def perform
      @booking = Booking.new(booking_params)
      @booking.approved = @user.admin? || ApplicationSetting.instance.auto_approve_bookings?
      @booking.user = @user
      populate_data_from_camdram
      setup_booking_purpose
      data = [@booking, @shows, @societies]
      raise NotAuthorisedOnCamdramException.new(data) unless booking_authorise_against_camdram?
      data
    end
  end
end
