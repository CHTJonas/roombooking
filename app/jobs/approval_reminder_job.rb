class ApprovalReminderJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Booking.where(approved: false).find_each(batch_size: 2) do |booking|
      User.where(admin: true).find_each(batch_size: 2) do |user|
        ApprovalsMailer.remind(user, booking).deliver_later
      end
    end
  end
end
