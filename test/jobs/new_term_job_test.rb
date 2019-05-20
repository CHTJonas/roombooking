require 'test_helper'

class NewTermJobTest < ActiveJob::TestCase
  test "should start a new term" do
    user = users(:charlie)
    assert_equal 0, NewTermJob.jobs.size
    NewTermJob.perform_async(user.id)
    assert_equal 1, NewTermJob.jobs.size
    NewTermJob.drain
    assert_equal 0, NewTermJob.jobs.size
    CamdramShow.all.each do |show|
      assert show.dormant
    end
  end
end
