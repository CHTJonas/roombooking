require 'test_helper'

class ContactFormMailerTest < ActionMailer::TestCase
  test "should email management contact form entries" do
    from = users(:charlie).email
    subject = "Does the contact form work?"
    message = "This is an exercise."
    email = ContactFormMailer.send_to_management(from, subject, message)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal ['roombooking@adctheatre.com'], email.from
    assert_equal ['production@adctheatre.com'], email.to
    assert_equal [from], email.reply_to
    assert_equal subject, email.subject
    assert email.html_part.body.to_s.include? read_fixture('send_to_management_html').join
    assert email.text_part.body.to_s.include? read_fixture('send_to_management_txt').join
  end
end
