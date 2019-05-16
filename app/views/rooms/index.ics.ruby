bookings = []
@rooms.each do |room|
  bookings += room.bookings
end
cal = IcalGenerationService.perform(bookings)
cal.publish
cal.to_ical
