# frozen_string_literal: true

class NotificationJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle threshold: {
    limit: 10, period: 1.hour, key_suffix: lambda do |booking_id, camdram_model_global_id|
      if camdram_model_global_id.present?
        camdram_model_global_id
      else
        booking_id
      end
    end
  }

  def perform(booking_id, camdram_model_global_id)
    @booking = Booking.find_by_id(booking_id)
    return unless @booking.present?
    @camdram_model = GlobalID::Locator.locate camdram_model_global_id if camdram_model_global_id
    if @camdram_model.present?
      notify_slack_webhook if @camdram_model.slack_webhook.present?
    end
  end

  private

  def message
    @message ||= begin
      msg = "A new #{@booking.room.name} booking has been made on #{@booking.start_time.strftime('%d/%m/%Y')} at #{@booking.start_time.strftime('%R')} – #{@booking.name}."
      msg += " Description:\n#{@booking.notes}" if @booking.notes.present?
      msg.freeze
    end
  end

  def notify_slack_webhook
    notifier = Slack::Notifier.new(@camdram_model.slack_webhook, username: 'Room Booking Bot')
    notifier.post(text: message, icon_url: Roombooking::Host.url('logo-square.png'))
  end
end
