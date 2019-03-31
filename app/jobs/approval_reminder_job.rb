# frozen_string_literal: true

class ApprovalReminderJob < ApplicationJob
  concurrency 1, drop: false

  def perform(*args)
    Booking.where(approved: false).find_each(batch_size: 5) do |booking|
      User.where(admin: true).each do |admin|
        ApprovalsMailer.remind(admin, booking).deliver_later
      end
    end
  end
end
