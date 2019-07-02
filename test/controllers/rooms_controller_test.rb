require 'test_helper'

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room = rooms(:two)
  end

  test "should show rooms index" do
    get rooms_url
    assert_response :success
    assert_select "h1", "Rooms"
    assert_select "ul > li:nth-child(1) > a", text: "Corpus Playroom"
    assert_select "ul > li:nth-child(2) > a", text: "ADC Theatre"
    assert_select "div.float-right.mt-1 > a", text: "Subscribe to iCal"
  end

  test "should show room" do
    get room_url(@room)
    assert_response :success
    assert_select "h1", "Room Calendar"
    assert_select "div.d-flex.flex-column.flex-md-row > div.align-self-md-center > div > a", "Back to Rooms"
  end

  test "anonymous user should not destroy room" do
    delete room_url(@room)
    assert_response :unauthorized
  end

  test "regular user should not destroy room" do
    sign_in_user
    delete room_url(@room)
    assert_response :forbidden
  end

  test "admin user should destroy room" do
    sign_in_admin
    assert_difference('Room.count', -1) do
      delete room_url(@room)
    end
    assert_redirected_to rooms_path
  end

  test "anonymous user should not update room" do
    new_name = "Porpus Clayroom"
    patch room_url(@room), params: { room: { name: new_name } }
    assert_response :unauthorized
  end

  test "regular user should not update room" do
    sign_in_user
    new_name = "Porpus Clayroom"
    patch room_url(@room), params: { room: { name: new_name } }
    assert_response :forbidden
  end

  test "should update room" do
    new_name = "Porpus Clayroom"
    sign_in_admin
    patch room_url(@room), params: { room: { name: new_name } }
    assert_redirected_to room_path(@room)
    assert_equal new_name, @room.reload.name
  end
end
