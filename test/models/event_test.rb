require 'test_helper'

class BookingTest < ActiveSupport::TestCase
  test "should return events in date range" do
    range_start = Time.zone.now.beginning_of_week - 2.days
    range_end = Time.zone.now.beginning_of_week + 1.day
    bookings = Booking.in_range(range_start, range_end)
    events = Event.from_bookings(bookings).sort_by(&:start_time)
    assert_equal 4, bookings.count
    assert_equal 7 + 7 + 1 + 1, events.count
    events.each_with_index do |event, index|
      if index >= 0 && index <= 6
        booking = bookings(:daily_repeat_booking_1)
        assert_equal booking.start_time + index.days, event.start_time
        assert_equal booking.end_time + index.days, event.end_time
        assert_equal booking, event.booking
      elsif index == 7
        booking = bookings(:weekly_repeat_booking_0)
        assert_equal booking.start_time, event.start_time
        assert_equal booking.end_time, event.end_time
        assert_equal booking, event.booking
      elsif index == 8
        booking = bookings(:ordinary_booking_0)
        assert_equal booking.start_time, event.start_time
        assert_equal booking.end_time, event.end_time
        assert_equal booking, event.booking
      else
        booking = bookings(:daily_repeat_booking_0)
        assert_equal booking.start_time + (index - 9).days, event.start_time
        assert_equal booking.end_time + (index - 9).days, event.end_time
        assert_equal booking, event.booking
      end
    end
  end
end
