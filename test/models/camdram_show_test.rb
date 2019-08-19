require 'test_helper'
require 'slack_test_helper'

class CamdramShowTest < ActiveSupport::TestCase
  include SlackTestHelper

  test "should not save if max_rehearsals is not an integer" do
    show = camdram_shows(:api_test_1)
    show.max_rehearsals = "some string"
    assert_not show.save
    show.max_rehearsals = :some_symbol
    assert_not show.save
    show.max_rehearsals = true
    assert_not show.save
    show.max_rehearsals = 5.5
    assert_not show.save
    show.max_rehearsals = -2
    assert_not show.save
    show.max_rehearsals = 12
    assert show.save
  end

  test "should not save if max_auditions is not an integer" do
    show = camdram_shows(:api_test_1)
    show.max_auditions = "some string"
    assert_not show.save
    show.max_auditions = :some_symbol
    assert_not show.save
    show.max_auditions = true
    assert_not show.save
    show.max_auditions = 5.5
    assert_not show.save
    show.max_auditions = -2
    assert_not show.save
    show.max_auditions = 12
    assert show.save
  end

  test "should not save if max_meetings is not an integer" do
    show = camdram_shows(:api_test_1)
    show.max_meetings = "some string"
    assert_not show.save
    show.max_meetings = :some_symbol
    assert_not show.save
    show.max_meetings = true
    assert_not show.save
    show.max_meetings = 5.5
    assert_not show.save
    show.max_meetings = -2
    assert_not show.save
    show.max_meetings = 12
    assert show.save
  end

  test "should validate Slack webhook URLs" do
    show = CamdramShow.new(camdram_id: 6451)
    validates_slack_webhook(show)
  end

  test "should not allow duplicate shows" do
    show = CamdramShow.new(camdram_id: 6514)
    assert_not show.save
  end

  test "should return show's camdram object" do
    show = camdram_shows(:api_test_1)
    obj = show.camdram_object
    assert_equal 6514, obj.id
    assert_equal "1997-api-test-1", obj.slug
    assert_equal "API Test 1", obj.name
    assert_equal "This show is a dummy used by Camdram for testing purposes only.", obj.description
  end

  test "should create show from a Camdram object" do
    Roombooking::CamdramApi.with do |client|
      obj = client.get_show(5471)
      assert_nothing_raised do
        CamdramShow.create_from_camdram(obj)
      end
    end
    # We end up creating a Camdram entity so we need to remove the generated
    # cache warmup jobs.
    CamdramEntityCacheWarmupJob.clear
  end

  test "should find show from a Camdram object" do
    Roombooking::CamdramApi.with do |client|
      obj = client.get_show(6514)
      show = camdram_shows(:api_test_1)
      assert show == CamdramShow.find_from_camdram(obj)
    end
  end

  test "should return camdram object name" do
    show = camdram_shows(:api_test_1)
    assert_equal "API Test 1", show.name
  end

  test "should return camdram object url" do
    show = camdram_shows(:api_test_1)
    assert_equal "https://www.camdram.net/shows/1997-api-test-1", show.url
  end
end
