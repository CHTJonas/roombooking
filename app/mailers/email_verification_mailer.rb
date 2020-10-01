# frozen_string_literal: true

class EmailVerificationMailer < ApplicationMailer
  # Sends an email to the user asking them to validate the email address for
  # their newly-created account.
  def notify(user_id)
    @user = User.find(user_id)
    return if @user.validated_at.present?

    if @user.validation_token.present?
      mail(to: @user.email, subject: 'Verify your email address')
    else
      raise Roombooking::InvalidStateError, "User with id #{@user.id} has no verification token"
    end
  end

  # Sends an email to the user reminding them that they have yet to complete the
  # signup process and validate their email address.
  def remind(user_id)
    @user = User.find(user_id)
    if @user.validation_token.present?
      mail(to: @user.email, subject: 'You have yet to verify your email address')
    else
      raise Roombooking::InvalidStateError, "User with id #{@user.id} has no verification token"
    end
  end
end
