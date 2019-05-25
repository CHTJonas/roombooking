require 'test_helper'

class BookingTest < ActiveSupport::TestCase
  test "should not save booking without name" do
    booking = Booking.new(booking_test_hash.except(:name))
    assert_not booking.save
  end

  test "should not save booking without start time" do
    booking = Booking.new(booking_test_hash.except(:start_time))
    assert_not booking.save
  end

  test "should not save booking without end time" do
    booking = Booking.new(booking_test_hash.except(:end_time))
    assert_not booking.save
  end

  test "should not save booking without purpose" do
    booking = Booking.new(booking_test_hash.except(:purpose))
    assert_not booking.save
  end

  test "should not save booking without room" do
    booking = Booking.new(booking_test_hash.except(:room))
    assert_not booking.save
  end

  test "should not save booking without user" do
    booking = Booking.new(booking_test_hash.except(:user))
    assert_not booking.save
  end

  test "should save booking" do
    booking = Booking.new(booking_test_hash)
    assert booking.save
  end

  private

  def booking_test_hash
    {
      name: 'Test Booking',
      start_time: DateTime.tomorrow + 14.hours,
      end_time: DateTime.tomorrow + 16.hours,
      purpose: 'other',
      room: rooms(:two),
      user: users(:jane)
    }
  end
end
