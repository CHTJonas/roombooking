module Roombooking
  module CamdramAPI
    class << self
      def client
        client_pool.checkout
      end

      def with(&block)
        client_pool.with &block
      end

      private

      def client_pool
        @client_pool ||= ConnectionPool.new(size: ENV.fetch('RAILS_MAX_THREADS') { 5 }, timeout: 3) do
          Camdram::Client.new do |config|
            app_id = Rails.application.credentials.dig(:camdram, :app_id)
            app_secret = Rails.application.credentials.dig(:camdram, :app_secret)
            config.client_credentials(app_id, app_secret)
            config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
            config.base_url = "https://www.camdram.net"
          end
        end
      end
    end
  end
end
