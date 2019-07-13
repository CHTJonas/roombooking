class ContactFormMailerPreview < ActionMailer::Preview
  def send_to_management
    from = "charlie@charliejonas.co.uk"
    subject = "Contact Form Test"
    message = "This is a test. This is only a test."
    ContactFormMailer.send_to_management(from, subject, message)
  end
end
