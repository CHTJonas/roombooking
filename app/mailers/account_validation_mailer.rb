# frozen_string_literal: true

class AccountValidationMailer < ApplicationMailer

  # Ask a user to validate the email address for their newly-created account.
  def notify(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, subject: 'Verify your email address')
  end
end
