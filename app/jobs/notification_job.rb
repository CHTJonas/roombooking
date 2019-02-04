class NotificationJob < ApplicationJob
  def perform(booking_id, entity_id, entity_type)
    klass = nil
    if entity_type == 'CamdramShow'
      klass = CamdramShow
    elsif entity_type == 'CamdramSociety'
      klass = CamdramSociety
    else
      raise 'Unknown entity_type!'
    end
    @entity = klass.find(entity_id)
    @booking = Booking.find(booking_id)
    notify_slack_webhook if @entity.slack_webhook.present?
  end

  private

  def message
    @message ||= (
      msg = "A new #{@booking.room.name} booking has been made on #{@booking.start_time.strftime('%d/%m/%Y')} at #{@booking.start_time.strftime('%R')} – #{@booking.name}."
      msg << " Description:\n#{@booking.notes}" if @booking.notes.present?
      msg
    )
  end

  def notify_slack_webhook
    notifier = Slack::Notifier.new(@entity.slack_webhook, username: 'Room Booking Bot')
    # FIXME use a better icon asset once deployed.
    notifier.post(text: message, icon_url: "https://www.adctheatre.com/assets/img/logo_500x500.png")
  end
end
