require 'test_helper'

class EmailVerificationReminderJobTest < ActiveJob::TestCase
  test "should send verification reminder" do
    assert_equal 0, EmailVerificationReminderJob.jobs.size
    assert_equal 0, MailDeliveryJob.jobs.size
    EmailVerificationReminderJob.perform_async
    assert_equal 1, EmailVerificationReminderJob.jobs.size
    EmailVerificationReminderJob.drain
    assert_equal 0, EmailVerificationReminderJob.jobs.size
    assert_equal 1, MailDeliveryJob.jobs.size
    MailDeliveryJob.jobs.clear
  end
end
