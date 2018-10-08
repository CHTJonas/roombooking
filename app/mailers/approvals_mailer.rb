class ApprovalsMailer < ApplicationMailer

  # Notify an admin that a new booking has been created that needs approval.
  def notify(admin, booking)
    @admin = admin
    @booking = booking
    mail(to: admin.email, subject: 'New room booking needs approval')
  end

  # Remind an admin that a booking exists which still needs approval.
  def remind(admin, booking)
    @admin = admin
    @booking = booking
    mail(to: admin.email, subject: 'Room booking approval reminder')
  end

  # Tell a user that their booking has been approved by an admin.
  def approve(user, booking)
    @user = user
    @booking = booking
    mail(to: user.email, subject: 'Your room booking has been approved')
  end
end
