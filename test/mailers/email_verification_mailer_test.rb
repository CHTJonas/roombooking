require 'test_helper'

class EmailVerificationMailerTest < ActionMailer::TestCase
  test 'should email a new user a verification link' do
    user = users(:bob)
    email = EmailVerificationMailer.create(user.id)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ['roombooking@adctheatre.com'], email.from
    assert_equal ['bob.builder@example.com'], email.to
    assert_equal 'Verify your email address', email.subject
    assert email.html_part.body.to_s.gsub(/\r\n?/, "\n").include? read_fixture('create_html').join
    assert email.text_part.body.to_s.gsub(/\r\n?/, "\n").include? read_fixture('create_txt').join
  end

  test 'should email user a verification reminder' do
    user = users(:bob)
    email = EmailVerificationMailer.remind(user.id)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ['roombooking@adctheatre.com'], email.from
    assert_equal ['bob.builder@example.com'], email.to
    assert_equal 'You have yet to verify your email address', email.subject
    assert email.html_part.body.to_s.gsub(/\r\n?/, "\n").include? read_fixture('remind_html').join
    assert email.text_part.body.to_s.gsub(/\r\n?/, "\n").include? read_fixture('remind_txt').join
  end
end
