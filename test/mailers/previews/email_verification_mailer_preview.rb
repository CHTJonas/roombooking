class EmailVerificationMailerPreview < ActionMailer::Preview
  def create
    user_id = User.first.id
    EmailVerificationMailer.create(user_id)
  end

  def update
    user_id = User.first.id
    EmailVerificationMailer.create(user_id)
  end

  def remind
    user_id = User.first.id
    EmailVerificationMailer.remind(user_id)
  end
end
