# frozen_string_literal: true

module Roombooking
  module CamdramAPI
    module ClientFactory
      class << self
        def new(token_hash = nil)
          Camdram::Client.new do |config|
            app_id     = Rails.application.credentials.dig(:camdram, :app_id)
            app_secret = Rails.application.credentials.dig(:camdram, :app_secret)
            if token_hash
              config.auth_code(token_hash, app_id, app_secret) do |faraday|
                faraday_connection_builder.call(faraday)
              end
            else
              config.client_credentials(app_id, app_secret) do |faraday|
                faraday_connection_builder(true).call(faraday)
              end
            end
            config.user_agent = Roombooking::CamdramAPI.user_agent
            config.base_url = Roombooking::CamdramAPI.base_url
          end
        end

        private

        def faraday_connection_builder(cache_responses = false)
          Proc.new do |faraday|
            faraday.use(:ddtrace) if ENV['ENABLE_DATADOG_APM']
            faraday.request  :url_encoded
            faraday.response :caching do
              Roombooking::CamdramAPI::ResponseCacheStore
            end if cache_responses
            faraday.response :logger, Yell['camdram'] do |logger|
              logger.filter(/Bearer[^"]*/m, '[FILTERED]')
            end
            # Patron is a native extension wrapper around libcurl and is
            # fater that Ruby's built in Net::HTTP, but it doesn't work
            # well on macOS. For that reason we only use the Patron adapter
            # if there is the appropriate environmental variable.
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
        end
      end
    end
  end
end
