# frozen_string_literal: true

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
              faraday.response :caching do
                Rails.cache
              end
              faraday.response :logger, Yell['camdram'] do |logger|
                logger.filter(/Bearer[^"]*/m, '[FILTERED]')
              end
              # Patron is a native extension wrapper around libcurl and is
              # fater that Ruby's built in Net::HTTP, but it doesn't work
              # well on macOS. For that reason we only configure Patron if
              # there is the appropriate environmental variable.
              if ENV['PATRON']
                faraday.adapter :patron do |session|
                  session.connect_timeout   = 1
                  session.timeout           = 3
                  session.dns_cache_timeout = 300
                  session.max_redirects     = 1
                end
              else
                faraday.adapter :net_http do |http|
                  http.open_timeout = 1
                  http.read_timeout = 3
                end
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
