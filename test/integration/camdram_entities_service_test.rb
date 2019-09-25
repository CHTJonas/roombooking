require 'test_helper'

class CamdramEntitiesServiceTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:charlie)
    @user = users(:jane)
  end

  test "should return an empty array of authorised Camdram entities if no user is given" do
    serv = CamdramEntitiesService.create(nil, nil)
    assert_equal [], serv.shows
    assert_equal [], serv.societies
  end

  test "should return an array of authorised Camdram entities for an admin" do
    serv = CamdramEntitiesService.create(@admin, nil)
    assert_equal CamdramShow.where(dormant: false, active: true), serv.shows
    assert_equal CamdramSociety.where(active: true), serv.societies
  end

  test "should return an array of authorised Camdram entities for an imposter" do
    serv = CamdramEntitiesService.create(@user, @admin)
    assert_equal CamdramShow.where(dormant: false, active: true), serv.shows
    assert_equal CamdramSociety.where(active: true), serv.societies
  end
end
