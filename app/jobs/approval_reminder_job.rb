# frozen_string_literal: true

class ApprovalReminderJob
  include Sidekiq::Worker
  sidekiq_options queue: 'roombooking_jobs'

  # concurrency 1, drop: false

  def perform
    Booking.where(approved: false).find_each(batch_size: 5) do |booking|
      User.where(admin: true).each do |admin|
        MailDeliveryJob.perform_async(ApprovalsMailer, :remind, admin.id, booking.id)
      end
    end
  end
end
