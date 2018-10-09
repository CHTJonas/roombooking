# Preview all emails at http://localhost:3000/rails/mailers/approvals_mailer
class ApprovalsMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/approvals_mailer/notify
  def notify
    ApprovalsMailer.notify(User.first, Booking.first)
  end

  # Preview this email at http://localhost:3000/rails/mailers/approvals_mailer/remind
  def remind
    ApprovalsMailer.remind(User.first, Booking.first)
  end

  # Preview this email at http://localhost:3000/rails/mailers/approvals_mailer/approve
  def approve
    ApprovalsMailer.approve(User.first, Booking.first)
  end

end
