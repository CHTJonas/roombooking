class ApprovalReminderJob < ApplicationJob
  def perform(*args)
    Booking.where(approved: false).find_each(batch_size: 5) do |booking|
      User.where(admin: true).each do |admin|
        ApprovalsMailer.remind(admin, booking).deliver_later
      end
    end
  end
end
