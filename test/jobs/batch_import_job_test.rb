require 'test_helper'

class BatchImportJobTest < ActiveJob::TestCase
  test 'should import shows' do
    user = users(:charlie)
    assert_equal 0, BatchImportJob.jobs.size
    result = BatchImportResult.create!(queued: Time.now)
    result.with_lock do
      jid = BatchImportJob.perform_async(user.id, result.id)
      result.update!(jid: jid)
    end
    assert_equal 1, BatchImportJob.jobs.size
    assert_equal 0, UserPermissionRefreshJob.jobs.size
    BatchImportJob.drain
    assert_equal 0, BatchImportJob.jobs.size
    assert_equal 1, UserPermissionRefreshJob.jobs.size
    UserPermissionRefreshJob.clear
    CamdramEntityCacheWarmupJob.drain
  end
end
