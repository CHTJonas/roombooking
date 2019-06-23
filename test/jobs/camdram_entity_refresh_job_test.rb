require 'test_helper'

class CamdramEntityRefreshJobTest < ActiveJob::TestCase
  test "should refresh all Camdram entities" do
    num_entities = CamdramShow.count + CamdramSociety.count + CamdramVenue.count
    assert_equal 0, CamdramEntityRefreshJob.jobs.size
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    CamdramEntityRefreshJob.perform_async
    assert_equal 1, CamdramEntityRefreshJob.jobs.size
    CamdramEntityRefreshJob.drain
    assert_equal 0, CamdramEntityRefreshJob.jobs.size
    assert_equal num_entities, CamdramEntityCacheWarmupJob.jobs.size
    CamdramEntityCacheWarmupJob.drain
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
  end
end
