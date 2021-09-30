require 'test_helper'

class CamdramEntitiesServiceTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:charlie)
    @user = users(:jane)
    @admin.refresh_permissions!
  end

  test 'should return an empty array of authorised Camdram entities if no user is given' do
    service = CamdramEntitiesService.create(nil, nil)
    assert_equal [], service.shows
    assert_equal [], service.societies
  end

  test 'should return an array of authorised Camdram entities for an admin' do
    service = CamdramEntitiesService.create(@admin, nil)
    assert_equal CamdramShow.where(active: true, dormant: false), service.shows
    assert_equal CamdramSociety.where(active: true), service.societies
  end

  test 'should return an array of authorised Camdram entities for an imposter' do
    service = CamdramEntitiesService.create(@user, @admin)
    assert_equal CamdramShow.where(active: true, dormant: false), service.shows
    assert_equal CamdramSociety.where(active: true), service.societies
  end
end
