# frozen_string_literal: true

module Roombooking
  module CamdramApi
    module ResponseCacheStore
      class << self
        # Support for the bare minimum of methods specified
        # by ActiveSupport::Cache::Store.

        def read(name)
          return nil unless perform_caching?
          key = "#{key_namespace}/#{trim_leading_slash(name)}"
          Rails.cache.read(key)
        end

        def write(name, value)
          return false unless perform_caching?
          key = "#{key_namespace}/#{trim_leading_slash(name)}"
          Rails.cache.write(key, value, expires_in: expiry_time)
        end

        def fetch(name, &block)
          key = "#{key_namespace}/#{trim_leading_slash(name)}"
          if block_given?
            return block.call(key)
            Rails.cache.fetch(key, expires_in: expiry_time, &block)
          else
            return nil unless perform_caching?
            Rails.cache.fetch(key)
          end
        end

        def trim_leading_slash(name)
          name.reverse.chomp("/").reverse
        end

        def key_namespace
          'camdram_api_responses'
        end

        def expiry_time
          8.hours
        end

        def kill_switch_key
          'cache_camdram_api_responses'
        end

        def perform_caching?
          master_cache = Rails.application.config.action_controller.perform_caching
          Rails.cache.fetch(kill_switch_key) { true } && (master_cache || Rails.env.test?)
        end

        def clear!
          Rails.cache.redis.keys.filter { |s| s.start_with? key_namespace }.each do |key|
            Rails.cache.delete(key)
          end
        end
      end
    end
  end
end
