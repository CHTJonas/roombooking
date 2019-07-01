require 'test_helper'

class RoomsControllerTest < ActionDispatch::IntegrationTest
  test "should show rooms index" do
    get rooms_url
    assert_response :success
    assert_select "h1", "Rooms"
    assert_select "body > main > ul > li:nth-child(1) > a", text: "Corpus Playroom"
    assert_select "body > main > ul > li:nth-child(2) > a", text: "ADC Theatre"
    assert_select "body > main > div.float-right.mt-1 > a", text: "Subscribe to iCal"
  end
end
