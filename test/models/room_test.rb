require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  test 'should not save room without name' do
    room = Room.new
    assert_not room.save
  end

  test 'should save with room' do
    room = Room.new(name: 'test')
    assert room.save
  end

  test 'should save with room and Camdram venue' do
    room = Room.new(name: 'test', camdram_venues: ['the-minack-theatre'])
    assert room.save
    room.destroy # We need to destroy the room to refresh the venue cache.
  end

  test 'should populate Camdram venue cache with initial values' do
    Roombooking::VenueCache.regenerate
    assert Roombooking::VenueCache.contains? 'adc-theatre'
    assert Roombooking::VenueCache.contains? 'corpus-playroom'
  end

  test 'should regenerate Camdram venue cache when creating room' do
    room = Room.create(name: 'test', camdram_venues: ['the-minack-theatre'])
    assert Roombooking::VenueCache.contains? 'the-minack-theatre'
    room.destroy # We need to destroy the room to refresh the venue cache.
  end

  test 'should regenerate Camdram venue cache when deleting room' do
    Room.find_by(name: 'Corpus Playroom').destroy
    assert_not Roombooking::VenueCache.contains? 'corpus-playroom'
  end

  test 'should regenerate Camdram venue cache when editing room' do
    room = Room.find_by(name: 'Corpus Playroom')
    room.update(camdram_venues: ['west-road-concert-hall'])
    assert Roombooking::VenueCache.contains? 'west-road-concert-hall'
    room.update(camdram_venues: ['corpus-playroom']) # Put things back.
  end
end
