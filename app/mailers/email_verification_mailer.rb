# frozen_string_literal: true

class EmailVerificationMailer < ApplicationMailer

  # Sends an email to the user asking them to validate the email address for
  # their newly-created account.
  def notify(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, subject: 'Verify your email address')
  end

  # Sends an email to the user reminding them that they have yet to complete the
  # signup process and validate their email address.
  def remind(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, subject: 'You have yet to verify your email address')
  end
end
