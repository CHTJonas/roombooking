# frozen_string_literal: true

class EmailDeliveryJob < ActionMailer::DeliveryJob
  queue_as :mail
end
