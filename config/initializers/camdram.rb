require 'camdram/client'

Rails.application.config.camdram_client_pool = ConnectionPool.new(size: 5, timeout: 5) do
  Camdram::Client.new do |config|
    app_id = Rails.application.credentials.dig(:camdram, :app_id)
    app_secret = Rails.application.credentials.dig(:camdram, :app_secret)
    config.client_credentials(app_id, app_secret)
    config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
    config.base_url = "https://www.camdram.net"
  end
end
