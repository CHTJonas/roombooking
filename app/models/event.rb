# Generated dynamically by the VenuesHelper module.
# Not stored in the database.
class Event
  attr_accessor :start_time, :end_time, :booking

  def self.create_from_booking(booking, offset = 0)
    evt = Event.new
    evt.start_time = booking.start_time + offset.days
    evt.end_time = booking.end_time + offset.days
    evt.booking = booking
    return evt
  end

  # Returns the duration of the event.
  def duration
    @duration ||= self.start_time && self.end_time ? self.end_time - self.start_time : nil
  end
end
