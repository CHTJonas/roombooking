require 'test_helper'

class CamdramShowTest < ActiveSupport::TestCase
  test "should not save if max_rehearsals is not an integer" do
    show = camdram_shows(:api_test_1)
    show.max_rehearsals = 'some string'
    assert_not show.save
    show.max_rehearsals = :some_symbol
    assert_not show.save
    show.max_rehearsals = true
    assert_not show.save
    show.max_rehearsals = 5.5
    assert_not show.save
    show.max_rehearsals = 12
    assert show.save
  end

  test "should not save if max_auditions is not an integer" do
    show = camdram_shows(:api_test_1)
    show.max_auditions = 'some string'
    assert_not show.save
    show.max_auditions = :some_symbol
    assert_not show.save
    show.max_auditions = true
    assert_not show.save
    show.max_auditions = 5.5
    assert_not show.save
    show.max_auditions = 12
    assert show.save
  end

  test "should not save if max_meetings is not an integer" do
    show = camdram_shows(:api_test_1)
    show.max_meetings = 'some string'
    assert_not show.save
    show.max_meetings = :some_symbol
    assert_not show.save
    show.max_meetings = true
    assert_not show.save
    show.max_meetings = 5.5
    assert_not show.save
    show.max_meetings = 12
    assert show.save
  end

  test "should return showiety's camdram object" do
    show = camdram_shows(:api_test_1)
    obj = show.camdram_object
    assert_equal 6514, obj.id
    assert_equal "1997-api-test-1", obj.slug
    assert_equal "API Test 1", obj.name
    assert_equal "This show is a dummy used by Camdram for testing purposes only.", obj.description
  end
end
