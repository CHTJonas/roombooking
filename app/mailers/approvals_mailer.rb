# frozen_string_literal: true

class ApprovalsMailer < ApplicationMailer

  # Notify an admin that a new booking has been created that needs approval.
  def notify(admin_id, booking_id)
    @admin = User.find(admin_id)
    @booking = Booking.find(booking_id)
    mail(to: @admin.email, subject: 'New room booking needs approval')
  end

  # Remind an admin that a booking exists which still needs approval.
  def remind(admin_id, booking_id)
    @admin = User.find(admin_id)
    @booking = Booking.find(booking_id)
    mail(to: @admin.email, subject: 'Room booking approval reminder')
  end

  # Tell a user that their booking has been approved by an admin.
  def approve(user_id, booking_id)
    @user = User.find(user_id)
    @booking = Booking.find(booking_id)
    mail(to: @user.email, subject: 'Your room booking has been approved')
  end
end
