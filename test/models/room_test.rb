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
    venue = CamdramVenue.create(camdram_id: 99)
    room = Room.new(name: "The Minack", camdram_venues: [venue])
    assert room.save
    # We end up creating a Camdram entity so we need to remove the generated
    # cache warmup jobs.
    CamdramEntityCacheWarmupJob.clear
  end
end
