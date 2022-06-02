require 'test_helper'

class CamdramVenueTest < ActiveSupport::TestCase
  test 'should not allow duplicate venues' do
    venue = CamdramVenue.new(camdram_id: 42)
    assert_not venue.save
  end

  test "should return venue's camdram object" do
    venue = camdram_venues(:west_road)
    obj = venue.camdram_object
    assert_equal 89, obj.id
    assert_equal 'west-road-concert-hall', obj.slug
    assert_equal 'West Road Concert Hall', obj.name
    assert_equal '11 West Road, Cambridge, CB3 9DP', obj.address
  end

  test 'should create venue from a Camdram object' do
    Roombooking::CamdramApi.with do |client|
      obj = client.get_venue(45)
      assert_nothing_raised do
        CamdramVenue.create_from_camdram(obj)
      end
    end
    # We end up creating a Camdram entity so we need to remove the generated
    # cache warmup jobs.
    CamdramEntityCacheWarmupJob.clear
  end

  test 'should find venue from a Camdram object' do
    Roombooking::CamdramApi.with do |client|
      obj = client.get_venue(30)
      venue = camdram_venues(:playroom)
      assert venue == CamdramVenue.find_from_camdram(obj)
    end
  end

  test 'should return camdram object name' do
    venue = camdram_venues(:fitzpat)
    assert_equal "Fitzpatrick Hall", venue.name
  end

  test 'should return camdram object url' do
    venue = camdram_venues(:fitzpat)
    assert_equal 'https://www.camdram.net/venues/fitzpatrick-hall', venue.url
  end
end
