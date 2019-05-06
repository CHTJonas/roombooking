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
    room = Room.new(name: 'test', camdram_venues: ['test'])
    assert room.save
  end

  test 'should populate Camdram venue cache with initial values' do
    Roombooking::VenueCache.regenerate
    assert Roombooking::VenueCache.contains? 'adc-theatre'
    assert Roombooking::VenueCache.contains? 'corpus-playroom'
  end

  test 'should regenerate Camdram venue cache when creating room' do
    Room.create(name: 'test', camdram_venues: ['test'])
    assert Roombooking::VenueCache.contains? 'test'
  end

  test 'should regenerate Camdram venue cache when deleting room' do
    Room.find_by(name: 'Corpus Playroom').destroy
    assert_not Roombooking::VenueCache.contains? 'corpus-playroom'
  end

  test 'should regenerate Camdram venue cache when editing room' do
    Room.find_by(name: 'Corpus Playroom').update(camdram_venues: ['testing-123'])
    assert Roombooking::VenueCache.contains? 'testing-123'
  end
end
