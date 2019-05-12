require 'test_helper'

class CamdramApiTest < ActionDispatch::IntegrationTest
  test "Camdram API client" do
    Roombooking::CamdramAPI.with do |client|
      assert_equal "https://www.camdram.net", client.base_url
      assert_equal "ADC Room Booking System/Git SHA #{Roombooking::VERSION}", client.user_agent
    end
  end

  test "fetch a user's societies from Camdram API" do
    Roombooking::CamdramAPI.with do |client|
      society = client.user.get_societies.first
      assert_equal 38, society.id
      assert_equal "camdram", society.slug
      assert_equal "Camdram", society.name
      assert_equal "Camdram's meta-page on Camdram. We don't fund any shows, but we help others to put on shows using this website.\r\n\r\nThe site is maintained by volunteers in their spare time. If you have a question or problem, or you\u2019re interested in helping, contact us at [support@camdram.net](mailto:support@camdram.net).", society.description
    end
  end

  test "fetch a user's shows from Camdram API" do
    Roombooking::CamdramAPI.with do |client|
      show = client.user.get_shows.first
      assert_equal 6514, show.id
      assert_equal "1997-api-test-1", show.slug
      assert_equal "API Test 1", show.name
      assert_equal "This show is a dummy used by Camdram for testing purposes only.", show.description
      assert_equal "ADC Theatre", show.other_venue
      assert_equal 29, show.performances.first.venue.id
      assert_equal "adc-theatre", show.performances.first.venue.slug
      assert_equal 38, show.society.id
      assert_equal "Camdram", show.society.name
    end
  end
end
