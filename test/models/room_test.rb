require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  test 'should not save room without name' do
    room = Room.new
    assert_not room.save
  end

  test 'should save room with name' do
    room = Room.new(name: 'The Minack')
    assert room.save
  end

  test 'should save room with name and Camdram venue' do
    venue = CamdramVenue.create(camdram_id: 99)
    room = Room.new(name: 'The Minack', camdram_venues: [venue])
    assert room.save
    # We end up creating a Camdram entity so we need to remove the generated
    # cache warmup jobs.
    CamdramEntityCacheWarmupJob.clear
  end

  test "should preserve a room's historic booking data" do
    room = rooms(:one)
    assert_not_equal 0, room.bookings.count
    assert_not room.destroy
    room.bookings.destroy_all
    assert_equal 0, room.bookings.count
    assert room.destroy
  end

  test "should return a room's ordinary booking at a given date" do
    room = rooms(:one)
    user = users(:charlie)
    time = Time.zone.now.in_time_zone('Europe/London').beginning_of_week + 10.hours
    booking = room.get_booking_at(time)
    assert_equal 'other', booking.purpose
    assert_equal user, booking.user
    assert_equal 'ordinary_booking_0', booking.name
  end

  test "should return a room's daily repeat booking at a given date" do
    room = rooms(:one)
    user = users(:charlie)
    time = Time.zone.now.in_time_zone('Europe/London').beginning_of_week - 2.weeks + 16.hours
    booking = room.get_booking_at(time)
    assert_equal 'other', booking.purpose
    assert_equal user, booking.user
    assert_equal 'daily_repeat_booking_2', booking.name
  end

  test "should return a room's weekly booking at a given date" do
    room = rooms(:one)
    user = users(:charlie)
    time = Time.zone.now.in_time_zone('Europe/London').beginning_of_week - 1.weeks + 9.hours + 30.minutes
    booking = room.get_booking_at(time)
    assert_equal 'other', booking.purpose
    assert_equal user, booking.user
    assert_equal 'weekly_repeat_booking_1', booking.name
  end
end
