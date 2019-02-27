# frozen_string_literal: true

class NotificationJob < ApplicationJob
  def perform(booking_id)
    @booking = Booking.find(booking_id)
    @entity = @booking.camdram_model
    notify_admins unless @booking.approved
    if @entity.present?
      notify_slack_webhook if @entity.slack_webhook.present?
    end
  end

  private

  def message
    @message ||= (
      msg = "A new #{@booking.room.name} booking has been made on #{@booking.start_time.strftime('%d/%m/%Y')} at #{@booking.start_time.strftime('%R')} – #{@booking.name}."
      msg << " Description:\n#{@booking.notes}" if @booking.notes.present?
      msg
    )
  end

  def notify_admins
    User.where(admin: true).each do |admin|
      ApprovalsMailer.notify(admin, @booking).deliver_later
    end
  end

  def notify_slack_webhook
    notifier = Slack::Notifier.new(@entity.slack_webhook, username: 'Room Booking Bot')
    # FIXME use a better icon asset once deployed.
    notifier.post(text: message, icon_url: "https://www.adctheatre.com/assets/img/logo_500x500.png")
  end
end
