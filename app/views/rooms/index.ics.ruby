bookings = Booking.all
cal = IcalGenerationService.perform(bookings)
cal.publish
cal.to_ical
