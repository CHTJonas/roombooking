class EmailVerificationMailerPreview < ActionMailer::Preview
  def notify
    user_id = User.first.id
    EmailVerificationMailer.notify(user_id)
  end

  def remind
    user_id = User.first.id
    EmailVerificationMailer.remind(user_id)
  end
end
