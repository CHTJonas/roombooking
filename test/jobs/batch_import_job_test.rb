require 'test_helper'

class BatchImportJobTest < ActiveJob::TestCase
  test "should import shows" do
    user = users(:charlie)
    assert_equal 0, BatchImportJob.jobs.size
    BatchImportJob.perform_async(user.id)
    assert_equal 1, BatchImportJob.jobs.size
    BatchImportJob.drain
    assert_equal 0, BatchImportJob.jobs.size
  end
end
