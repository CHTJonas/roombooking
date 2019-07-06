class EmailVerificationMailerPreview < ActionMailer::Preview
  def notify
    user_id = User.first.id
    EmailVerificationMailer.notify(user_id)
  end
end
