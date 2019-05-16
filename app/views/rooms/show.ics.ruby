cal = IcalGenerationService.perform(@room.bookings)
cal.publish
cal.to_ical
