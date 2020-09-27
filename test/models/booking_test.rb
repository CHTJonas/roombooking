require 'test_helper'

class BookingTest < ActiveSupport::TestCase
  teardown do
    travel_back
  end

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

  test "should not save booking in past" do
    booking = Booking.new(booking_test_hash)
    booking.start_time -= 6.months
    booking.end_time -= 6.months
    assert_not booking.save
  end

  test "should not save booking too far in the future" do
    booking = Booking.new(booking_test_hash)
    booking.start_time += 6.months
    booking.end_time += 6.months
    assert_not booking.save
  end

  test "should not save booking during quiet hours" do
    booking = Booking.new(booking_test_hash)
    booking.start_time = DateTime.tomorrow + 5.hours
    booking.end_time = DateTime.tomorrow + 10.hours
    assert_not booking.save
    booking = Booking.new(booking_test_hash)
    booking.start_time = DateTime.tomorrow + 23.hours
    booking.end_time = DateTime.tomorrow + 25.hours
    assert_not booking.save
  end

  test "should not save booking unless the end time is on the same day as the start time" do
    # Bookings ending the following day at midnight are okay.
    booking = Booking.new(booking_test_hash)
    booking.user = users(:charlie)
    booking.start_time = DateTime.tomorrow + 19.hours
    booking.end_time = DateTime.tomorrow + 24.hours
    assert booking.save
    # But anything after that is not!
    booking = Booking.new(booking_test_hash)
    booking.start_time = DateTime.tomorrow + 19.hours
    booking.end_time = DateTime.tomorrow + 34.hours
    assert_not booking.save
  end

  test "should not save booking unless times align to the half-hour" do
    booking = Booking.new(booking_test_hash)
    booking.start_time += 15.minutes
    assert_not booking.save
    booking = Booking.new(booking_test_hash)
    booking.end_time += 15.minutes
    assert_not booking.save
    booking = Booking.new(booking_test_hash)
    booking.start_time += 15.minutes
    booking.end_time += 15.minutes
    assert_not booking.save
  end

  test "must not save repeating booking without a repeat until date" do
    booking = Booking.new(booking_test_hash)
    booking.repeat_mode = :daily
    assert_not booking.save
    booking.repeat_mode = :weekly
    assert_not booking.save
    booking.repeat_mode = :none
    assert booking.save
  end

  test "should not save booking if Camdram venue is not permitted" do
    booking = Booking.new(booking_test_hash)
    booking.purpose = :rehearsal_for
    booking.camdram_model = camdram_shows(:spring_awakening)
    assert_not booking.save
  end

  test "should not save booking if name is similar to user's name" do
    booking = Booking.new(booking_test_hash)
    booking.name = 'jane doe'
    assert_not booking.save
    booking.name = 'Jane Doe'
    assert_not booking.save
    booking.name = 'jANEdOE'
    assert_not booking.save
    booking.name = 'Jåné dÖe'
    assert_not booking.save
  end

  test "should not save booking if name is similar to Camdram entity's name" do
    booking = Booking.new(booking_test_hash)
    booking.purpose = :rehearsal_for
    booking.camdram_model = camdram_shows(:spring_awakening)
    booking.name = 'spring awakening'
    assert_not booking.save
    booking.name = 'Spring Awakening'
    assert_not booking.save
    booking.name = 'sPrInG aWaKeNiNg'
    assert_not booking.save
    booking.name = 'Sprïng Awákênīng'
    assert_not booking.save
  end

  test "should not save booking if booking date is after the show's last performance" do
    booking = Booking.new(booking_test_hash)
    booking.start_time += 2.weeks
    booking.end_time += 2.weeks
    booking.purpose = :rehearsal_for
    booking.camdram_model = camdram_shows(:spring_awakening)
    booking.room = rooms(:one)
    assert_not booking.save
  end

  test "should save booking if Camdram venue is permitted" do
    booking = Booking.new(booking_test_hash)
    booking.purpose = :rehearsal_for
    booking.camdram_model = camdram_shows(:spring_awakening)
    booking.room = rooms(:one)
    assert booking.save
  end

  test "should save booking" do
    booking = Booking.new(booking_test_hash)
    assert booking.save
  end

  test "should return stringified length" do
    start_time = DateTime.parse('2019-01-01 12:00')
    end_time = DateTime.parse('2019-01-01 15:30')
    booking = Booking.new(start_time: start_time, end_time: end_time)
    assert_equal "3 hours 30 minutes", booking.length
  end

  test "should set end time from stringified length" do
    start_time = DateTime.parse('2019-01-01 12:00')
    booking = Booking.new(start_time: start_time)
    booking.length = "1 hour 30 minutes"
    assert_equal DateTime.parse('2019-01-01 13:30'), booking.end_time
    booking.length = "7200"
    assert_equal DateTime.parse('2019-01-01 14:00'), booking.end_time
  end

  test "should return human-friendly purpose string" do
    booking = Booking.new(booking_test_hash)
    booking.purpose = :rehearsal_for
    booking.camdram_model = camdram_shows(:spring_awakening)
    assert_equal 'Rehearsal for "Spring Awakening"', booking.purpose_string
  end

  test "should return Camdram object" do
    booking = Booking.new(booking_test_hash)
    booking.purpose = :rehearsal_for
    booking.camdram_model = camdram_shows(:spring_awakening)
    assert_equal camdram_shows(:spring_awakening).camdram_object, booking.camdram_object
  end

  test "should return ordinary bookings in range" do
    week_start = Time.zone.today.beginning_of_week
    week_end = week_start + 6.days
    bookings = Booking.ordinary_in_range(week_start, week_end)
    assert_equal 6, bookings.count
    bookings.each do |booking|
      assert_equal 'none', booking.repeat_mode
      assert_match /ordinary_booking_\d/, booking.name
    end
  end

  test "should return daily repeat bookings in range" do
    range_end = Time.zone.today.beginning_of_week + 1.day
    range_start = Time.zone.today.beginning_of_week - 3.weeks
    test_daily_repeat_bookings(range_start, range_end)
  end

  test "should return daily repeat bookings in offset range" do
    range_end = Time.zone.today.beginning_of_week + 1.day + 3.days
    range_start = Time.zone.today.beginning_of_week - 3.weeks + 3.days
    test_daily_repeat_bookings(range_start, range_end)
  end

  test "should return weekly repeat bookings in range" do
    range_end = Time.zone.today.beginning_of_week + 1.day
    range_start = Time.zone.today.beginning_of_week - 2.weeks
    test_weekly_repeat_bookings(range_start, range_end)
  end

  test "should not save booking without attendees listed" do
    booking = Booking.new(booking_test_hash.except(:attendees))
    booking.purpose = :rehearsal_for
    booking.camdram_model = camdram_shows(:spring_awakening)
    booking.room = rooms(:one)
    assert_not booking.save
    booking.attendees_text = "Test"
    assert_not booking.save
    booking.attendees_text = "tony@example.com"
    assert_not booking.save
    booking.attendees_text = "<tony@example.com>"
    assert_not booking.save
    booking.attendees_text = " <tony@example.com>"
    assert_not booking.save
    booking.attendees_text = "<tony@example.com> "
    assert_not booking.save
    booking.attendees_text = "Tony <tony@example.com> "
    assert_not booking.save
    booking.attendees_text = "Tony <tony@example.com> Johnston"
    assert_not booking.save
    booking.attendees_text = "Tony Johnston <tony@example.com> "
    assert_not booking.save
    booking.attendees_text = "Tony Johnston <tony@example.com>"
    assert booking.save
  end

  test "admins should be able to override attendee registration" do
    booking = Booking.new(booking_test_hash.except(:attendees))
    booking.purpose = :training
    assert booking.save
    booking.purpose = :other
    assert booking.save
    booking.purpose = :theatre_closed
    assert booking.save
    booking.camdram_model = camdram_shows(:spring_awakening)
    booking.room = rooms(:one)
    booking.purpose = :get_in_for
    assert booking.save
    booking.purpose = :performance_of
    assert booking.save
  end

  test "non-admins should not be allowed to make bookings outside office hours" do
    booking = Booking.new(booking_test_hash)
    assert booking.save
    booking.end_time = DateTime.tomorrow + 19.hours + 2.weeks
    assert_not booking.save
    booking.start_time = DateTime.tomorrow + 18.hours + 2.weeks
    booking.end_time = DateTime.tomorrow + 20.hours + 2.weeks
    assert_not booking.save
    # Admin override
    booking.user = users(:charlie)
    assert booking.save
  end

  private

  def booking_test_hash
    travel_to Time.zone.local(2016, 1, 9, 12, 26, 44)
    {
      name: 'Test Booking',
      start_time: DateTime.tomorrow + 14.hours + 2.weeks,
      end_time: DateTime.tomorrow + 16.hours + 2.weeks,
      purpose: 'other',
      room: rooms(:two),
      user: users(:jane),
      attendees: [attendees(:christine)]
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
