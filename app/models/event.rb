# frozen_string_literal: true

class Event
  attr_reader :start_time, :end_time, :booking

  # Instantiates a new event of the given booking at the starting and ending
  # times specified.
  def initialize(start_time, end_time, booking)
    @start_time = start_time
    @end_time = end_time
    @booking = booking
  end

  # Converts each booking to an event and returns an array of such events.
  def self.from_bookings(bookings)
    events = LinkedList::List.new
    bookings.each do |booking|
      booking.repeat_iterator do |st, et|
        event = Event.new(st, et, booking)
        events.push(event)
      end
    end
    events.to_a
  end

  # Returns the duration of the event.
  def duration
    @duration ||= start_time && end_time ? end_time - start_time : nil
  end
end
