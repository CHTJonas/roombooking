class EmailDeliveryJob < ActionMailer::DeliveryJob
  queue_as :mail
end
