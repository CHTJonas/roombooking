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
        rescue Exception => e
          raise CamdramError.new, e
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
