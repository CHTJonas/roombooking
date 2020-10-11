require 'test_helper'

class UserPermissionRefreshJobTest < ActiveJob::TestCase
  test 'should refresh permissions of all users' do
    assert_equal 0, UserPermissionRefreshJob.jobs.size
    assert_equal [], users(:charlie).camdram_shows
    assert_equal [], users(:charlie).camdram_societies
    UserPermissionRefreshJob.perform_async
    assert_equal 1, UserPermissionRefreshJob.jobs.size
    UserPermissionRefreshJob.drain
    assert_equal 0, UserPermissionRefreshJob.jobs.size
    assert_equal CamdramShow.where(dormant: false, active: true), users(:charlie).reload.camdram_shows
    assert_equal CamdramSociety.where(active: true), users(:charlie).reload.camdram_societies
  end
end
