bookings = []
@rooms.each do |room|
  bookings += room.approved_bookings
end
cal = IcalGenerationService.perform(bookings)
cal.publish
cal.to_ical
