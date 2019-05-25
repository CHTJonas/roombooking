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

  test "should return ordinary bookings in range" do
    week_start = Date.today.beginning_of_week
    week_end = week_start + 6.days
    bookings = Booking.ordinary_in_range(week_start, week_end)
    assert_equal 6, bookings.count
    bookings.each do |booking|
      assert_equal 'none', booking.repeat_mode
      assert_match /ordinary_booking_\d/, booking.name
    end
  end

  test "should return daily repeat bookings in range" do
    range_end = Date.today.beginning_of_week + 1.day
    range_start = Date.today.beginning_of_week - 3.weeks
    test_daily_repeat_bookings(range_start, range_end)
  end

  test "should return daily repeat bookings in offset range" do
    range_end = Date.today.beginning_of_week + 1.day + 3.days
    range_start = Date.today.beginning_of_week - 3.weeks + 3.days
    test_daily_repeat_bookings(range_start, range_end)
  end

  test "should return weekly repeat bookings in range" do
    range_end = Date.today.beginning_of_week + 1.day
    range_start = Date.today.beginning_of_week - 2.weeks
    test_weekly_repeat_bookings(range_start, range_end)
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

  def test_daily_repeat_bookings(range_start, range_end)
    bookings = Booking.daily_repeat_in_range(range_start, range_end)
    assert_equal 4, bookings.count
    bookings.each do |booking|
      assert_equal 'daily', booking.repeat_mode
      assert_match /daily_repeat_booking_\d/, booking.name
    end
  end

  def test_weekly_repeat_bookings(range_start, range_end)
    bookings = Booking.weekly_repeat_in_range(range_start, range_end)
    assert_equal 3, bookings.count
    bookings.each do |booking|
      assert_equal 'weekly', booking.repeat_mode
      assert_match /weekly_repeat_booking_\d/, booking.name
    end
  end
end
