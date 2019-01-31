module Roombooking
  module CamdramAPI
    class CamdramError < StandardError; end
    class << self
      def client
        client_pool.checkout
      end

      def with(&block)
        client_pool.with do |client|
          block.call(client)
        rescue Exception => e
          raise CamdramError.new, e
        end
      end

      def url_for(entity)
        client.base_url + entity.url_slug.chomp('.json')
      end

      private

      def client_pool
        @client_pool ||= ConnectionPool.new(size: ENV.fetch('RAILS_MAX_THREADS') { 5 }, timeout: 3) do
          Camdram::Client.new do |config|
            app_id     = Rails.application.credentials.dig(:camdram, :app_id)
            app_secret = Rails.application.credentials.dig(:camdram, :app_secret)
            config.client_credentials(app_id, app_secret) do |faraday|
              faraday.request  :url_encoded
              faraday.adapter  :patron do |session|
                session.connect_timeout   = 1
                session.timeout           = 3
                session.dns_cache_timeout = 300
                session.max_redirects     = 1
              end
            end
            config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
            config.base_url = "https://www.camdram.net"
          end
        end
      end
    end
  end
end
