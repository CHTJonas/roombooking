require 'test_helper'

class CamdramEntityCacheWarmupJobTest < ActiveJob::TestCase
  test "should warmup cache of a Camdram show" do
    camdram_show = camdram_shows(:api_test_2)
    global_id = camdram_show.to_global_id.to_s
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    assert_nil Rails.cache.read("#{camdram_show.cache_key}/name")
    CamdramEntityCacheWarmupJob.perform_async(global_id)
    assert_equal 1, CamdramEntityCacheWarmupJob.jobs.size
    CamdramEntityCacheWarmupJob.drain
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    assert_not_nil Rails.cache.read("#{camdram_show.cache_key}/name")
  end

  test "should warmup cache of a Camdram society" do
    camdram_society = camdram_societies(:camdram)
    global_id = camdram_society.to_global_id.to_s
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    assert_nil Rails.cache.read("#{camdram_society.cache_key}/name")
    CamdramEntityCacheWarmupJob.perform_async(global_id)
    assert_equal 1, CamdramEntityCacheWarmupJob.jobs.size
    CamdramEntityCacheWarmupJob.drain
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    assert_not_nil Rails.cache.read("#{camdram_society.cache_key}/name")
  end
end
