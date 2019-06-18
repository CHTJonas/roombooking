require 'test_helper'

class EmailTest < ActiveSupport::TestCase
  test "should not validate email without from" do
    email = Email.new(email_test_hash.except(:from))
    assert_not email.valid?
  end

  test "should not validate email without to" do
    email = Email.new(email_test_hash.except(:to))
    assert_not email.valid?
  end

  test "should not validate email without subject" do
    email = Email.new(email_test_hash.except(:subject))
    assert_not email.valid?
  end

  test "should not validate email without body" do
    email = Email.new(email_test_hash.except(:body))
    assert_not email.valid?
  end

  test "should validate email" do
    email = Email.new(email_test_hash)
    assert email.valid?
  end

  private

  def email_test_hash
    {
      from: 'bob@example.com',
      to: 'alice@example.com',
      subject: 'Test',
      body: 'This is a test messge.'
    }
  end
end
