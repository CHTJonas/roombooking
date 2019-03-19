cal = Icalendar::Calendar.new

tzid = 'Europe/London'
cal.timezone do |t|
  t.tzid = tzid

  t.daylight do |d|
    d.tzoffsetfrom = '+0000'
    d.tzoffsetto   = '+0100'
    d.tzname       = 'BST'
    d.dtstart      = '19810329T010000'
    d.rrule        = 'FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU'
  end

  t.standard do |s|
    s.tzoffsetfrom = '+0100'
    s.tzoffsetto   = '+0000'
    s.tzname       = 'GMT'
    s.dtstart      = '19961027T020000'
    s.rrule        = 'FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU'
  end
end

@room.booking.each do |booking|
  cal.event do |e|
    e.dtstart     = Icalendar::Values::DateTime.new(booking.start_time, 'tzid' => tzid)
    e.dtend       = Icalendar::Values::DateTime.new(booking.end_time, 'tzid' => tzid)
    unless booking.repeat_mode == 'none'
      e.rrule       = "FREQ=#{booking.repeat_mode};UNTIL=#{(booking.repeat_until + 1.day).strftime("%Y%m%d")}"
    end
    e.summary     = booking.name
    e.description = "Purpose: #{booking.purpose_string}\n\n#{booking.notes}"
    e.location    = @room.name
    e.organizer   = booking.user.name
    e.url         = booking_url(booking)
  end
end

cal.publish
cal.to_ical
