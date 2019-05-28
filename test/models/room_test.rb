require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  test "should not save room without name" do
    room = Room.new
    assert_not room.save
  end

  test "should save room with name" do
    room = Room.new(name: "The Minack")
    assert room.save
  end

  test "should save room with name and Camdram venue" do
    room = Room.new(name: "The Minack", camdram_venues: ["the-minack-theatre"])
    assert room.save
  end

  test "should regenerate Camdram venue cache when creating room" do
    room = Room.create(name: "test", camdram_venues: ["the-minack-theatre"])
    assert Roombooking::VenueCache.contains? "the-minack-theatre"
  end

  test "should regenerate Camdram venue cache when deleting room" do
    Room.find_by(name: "Corpus Playroom").destroy
    assert_not Roombooking::VenueCache.contains? "corpus-playroom"
  end

  test "should regenerate Camdram venue cache when editing room" do
    room = Room.find_by(name: "Corpus Playroom")
    room.update(camdram_venues: ["west-road-concert-hall"])
    assert Roombooking::VenueCache.contains? "west-road-concert-hall"
  end

  teardown do
    Roombooking::VenueCache.regenerate
  end
end
