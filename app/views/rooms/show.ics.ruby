cal = IcalGenerationService.perform(@room.approved_bookings)
cal.publish
cal.to_ical
