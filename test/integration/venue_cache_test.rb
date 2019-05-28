require 'test_helper'

class VenueCacheTest < ActionDispatch::IntegrationTest
  test "should populate Camdram venue cache with initial values" do
    assert Roombooking::VenueCache.contains? "adc-theatre"
    assert Roombooking::VenueCache.contains? "corpus-playroom"
  end

  test "should regenerate Camdram venue cache" do
    Roombooking::VenueCache.regenerate
  end
end
