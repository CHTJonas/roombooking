# frozen_string_literal: true

class ApprovalReminderJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    Booking.where(approved: false).find_each(batch_size: 5) do |booking|
      User.where(admin: true).each do |admin|
        MailDeliveryJob.perform_async(ApprovalsMailer, :remind, admin.id, booking.id)
      end
    end
  end
end
