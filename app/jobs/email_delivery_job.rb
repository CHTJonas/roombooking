# frozen_string_literal: true

class EmailDeliveryJob < ActionMailer::DeliveryJob
  queue_as :mail
  throttle threshold: 60, period: 1.hour
end
