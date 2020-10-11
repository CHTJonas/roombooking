require 'test_helper'

class ContactFormSubmissionTest < ActiveSupport::TestCase
  test 'should not validate email without from' do
    email = ContactFormSubmission.new(email_test_hash.except('from'))
    assert_not email.valid?
  end

  test 'should not validate email without subject' do
    email = ContactFormSubmission.new(email_test_hash.except('subject'))
    assert_not email.valid?
  end

  test 'should not validate email without message' do
    email = ContactFormSubmission.new(email_test_hash.except('message'))
    assert_not email.valid?
  end

  test 'should validate email' do
    email = ContactFormSubmission.new(email_test_hash)
    assert email.valid?
  end

  private

  def email_test_hash
    {
      'from'    => 'bob@example.com',
      'subject' => 'Test',
      'message' => 'This is a test messge.'
    }
  end
end
