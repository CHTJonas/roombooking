require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  test "should parse an email" do
    assert_not Attendee.parse "Test"
    assert_not Attendee.parse "tony@example.com"
    assert_not Attendee.parse "<tony@example.com>"
    assert_not Attendee.parse " <tony@example.com>"
    assert_not Attendee.parse "<tony@example.com> "
    assert_not Attendee.parse "Tony <tony@example.com> "
    assert_not Attendee.parse "Tony <tony@example.com> Johnston"
    assert_not Attendee.parse "Tony Johnston <tony@example.com> "
    assert Attendee.parse "Tony Johnston <tony@example.com>"
  end

  test "should format an attendee record as a string" do
    assert_equal "Chris Yates <chris@yates.me.uk>", attendees(:chris).to_s
    assert_equal "Christine Yates <christine@yates.me.uk>", attendees(:christine).to_s
  end
end
