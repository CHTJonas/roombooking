require 'test_helper'

class CamdramEntityCacheWarmupJobTest < ActiveJob::TestCase
  test "should warmup cache of a Camdram show" do
    camdram_show = camdram_shows(:api_test_2)
    global_id = camdram_show.to_global_id.to_s
    cache_key = "#{camdram_show.cache_key}/name"
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    Rails.cache.delete(cache_key)
    CamdramEntityCacheWarmupJob.perform_async(global_id)
    assert_equal 1, CamdramEntityCacheWarmupJob.jobs.size
    CamdramEntityCacheWarmupJob.drain
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    assert_equal "API Test 2", Rails.cache.read(cache_key)
  end

  test "should warmup cache of a Camdram society" do
    camdram_society = camdram_societies(:camdram)
    global_id = camdram_society.to_global_id.to_s
    cache_key = "#{camdram_society.cache_key}/name"
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    Rails.cache.delete(cache_key)
    CamdramEntityCacheWarmupJob.perform_async(global_id)
    assert_equal 1, CamdramEntityCacheWarmupJob.jobs.size
    CamdramEntityCacheWarmupJob.drain
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    assert_equal "Camdram", Rails.cache.read(cache_key)
  end

  test "should warmup cache of a Camdram venue" do
    camdram_venue = camdram_venues(:west_road)
    global_id = camdram_venue.to_global_id.to_s
    cache_key = "#{camdram_venue.cache_key}/name"
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    Rails.cache.delete(cache_key)
    CamdramEntityCacheWarmupJob.perform_async(global_id)
    assert_equal 1, CamdramEntityCacheWarmupJob.jobs.size
    CamdramEntityCacheWarmupJob.drain
    assert_equal 0, CamdramEntityCacheWarmupJob.jobs.size
    assert_equal "West Road Concert Hall", Rails.cache.read(cache_key)
  end
end
