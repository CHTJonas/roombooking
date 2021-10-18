# frozen_string_literal: true

class EmailVerificationReminderJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    User.where(validated_at: nil).find_each(batch_size: 10) do |user|
      EmailVerificationMailer.deliver_async.remind(user.id)
    end
  end
end
