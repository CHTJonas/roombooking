# frozen_string_literal: true

module Roombooking
  module CamdramApi
    class << self
      def user_agent
        @user_agent ||= "ADC Room Booking System/#{Roombooking::Version.git_description} (+https://github.com/CHTJonas/roombooking)"
      end

      def base_url
        @base_url ||= 'https://www.camdram.net'
      end

      def with(&block)
        client_pool.with do |client|
          block.call(client)
        end
      end

      def with_retry(count: 5, wait_time: 5, &block)
        retries ||= 0
        if block.arity == 0
          block.call
        else
          with(&block)
        end
      rescue Camdram::Error::ServerError, Camdram::Error::Timeout => e
        if (retries += 1) < count
          sleep wait_time # Sleep for a short while in case Camdram is overloaded.
          retry
        else
          raise e
        end
      end

      private

      def client_pool
        @client_pool ||= ConnectionPool.new(size: ENV.fetch('RAILS_MAX_THREADS') { 5 }, timeout: wait_timeout) do
          Roombooking::CamdramApi::ClientFactory.new
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
