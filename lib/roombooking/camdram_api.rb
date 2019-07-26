# frozen_string_literal: true

module Roombooking
  module CamdramAPI
    class << self
      def user_agent
        @user_agent ||= "ADC Room Booking System/Git SHA #{Roombooking::VERSION}".freeze
      end

      def base_url
        @base_url ||= 'https://www.camdram.net'
      end

      def url_for(entity)
        base_url + entity.url_slug.chomp('.json')
      end

      def with(&block)
        client_pool.with do |client|
          block.call(client)
        rescue OAuth2::Error => e
          http_status = e.code['code']
          if http_status.between?(400, 499)
            raise Roombooking::CamdramAPI::ClientError.new, e
          elsif http_status.between?(500, 599)
            raise Roombooking::CamdramAPI::ServerError.new, e
          else
            raise Roombooking::CamdramAPI::CamdramError.new, e
          end
        rescue Faraday::TimeoutError => e
          raise Roombooking::CamdramAPI::TimeoutError.new, e
        rescue Faraday::ConnectionFailed => e
          if e.wrapped_exception.class == Net::OpenTimeout
            raise Roombooking::CamdramAPI::TimeoutError.new, e
          else
            raise Roombooking::CamdramAPI::CamdramError.new, e
          end
        rescue => e
          raise Roombooking::CamdramAPI::CamdramError.new, e
        end
      end

      def with_retry(count: 5, wait_time: 5, &block)
        begin
          retries ||= 0
          if block.arity == 0
            block.call
          else
            with(&block)
          end
        rescue CamdramAPI::ServerError, Roombooking::CamdramAPI::TimeoutError => e
          if (retries += 1) < count
            sleep wait_time # Sleep for a short while in case Camdram is overloaded.
            retry
          else
            raise e
          end
        end
      end

      private

      def client_pool
        @client_pool ||= ConnectionPool.new(size: ENV.fetch('RAILS_MAX_THREADS') { 5 }, timeout: wait_timeout) do
          Roombooking::CamdramAPI::ClientFactory.new
        end
      end

      def wait_timeout
        if Sidekiq.server?
          10
        else
          3
        end
      end
    end
  end
end
