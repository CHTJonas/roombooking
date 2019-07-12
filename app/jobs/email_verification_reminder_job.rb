# frozen_string_literal: true

class EmailVerificationReminderJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    User.where(validated_at: nil).each do |user|
      if user.validation_token.present?
        mailer = 'EmailVerificationMailer'
        method = 'remind'
        user_id = user.id
        MailDeliveryJob.perform_async(mailer, method, user_id)
      else
        e = Roombooking::InvalidStateError.new("Detected user (id: #{user.id}) with unverified email but no verification token")
        Raven.capture_exception(e)
      end
    end
  end
end
