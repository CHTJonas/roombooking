# frozen_string_literal: true

class Event
  attr_accessor :start_time, :end_time, :booking

  # Converts each booking to an event and returns an array of such events.
  def self.from_bookings(bookings)
    events = LinkedList::List.new
    bookings.each do |booking|
      booking.repeat_iterator do |st, et|
        evt = Event.new
        evt.start_time = st
        evt.end_time = et
        evt.booking = booking
        events.push(evt)
      end
    end
    events.to_a
  end

  # Returns the duration of the event.
  def duration
    @duration ||= self.start_time && self.end_time ? self.end_time - self.start_time : nil
  end
end
