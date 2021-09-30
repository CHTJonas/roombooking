# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__) unless defined? Rails

class ApplicationCollector < PrometheusExporter::Server::TypeCollector
  def initialize
    @user_count = PrometheusExporter::Metric::Gauge.new('user_count', 'Total number of registered users')
    @booking_count = PrometheusExporter::Metric::Gauge.new('booking_count', 'Total number of bookings made')
    @camdram_show_count = PrometheusExporter::Metric::Gauge.new('camdram_show_count', 'Total number of active Camdram shows')
    @camdram_society_count = PrometheusExporter::Metric::Gauge.new('camdram_society_count', 'Total number of active Camdram societies')
    @email_count = PrometheusExporter::Metric::Gauge.new('email_count', 'Total number of emails sent')
  end

  def type
    'app_global'
  end

  def observe(obj)
    # do nothing, we would only use this if metrics are transported from apps
  end

  def metrics
    @user_count.observe User.count
    @booking_count.observe Booking.count
    @camdram_show_count.observe CamdramShow.where(active: true, dormant: false).count
    @camdram_society_count.observe CamdramSociety.count
    @email_count.observe Email.count

    [
      @user_count,
      @booking_count,
      @camdram_show_count,
      @camdram_society_count,
      @email_count
    ]
  end
end
