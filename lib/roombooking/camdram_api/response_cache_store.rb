# frozen_string_literal: true

module Roombooking
  module CamdramAPI
    module ResponseCacheStore
      class << self
        # Support for the bare minimum of methods specified
        # by ActiveSupport::Cache::Store.

        def read(name)
          key = "#{cache_namespace}/#{name}"
          Rails.cache.read(key)
        end

        def write(name, value)
          key = "#{cache_namespace}/#{name}"
          Rails.cache.write(key, value, expires_in: expiry_time)
        end

        def fetch(name, &block)
          key = "#{cache_namespace}/#{name}"
          if block_given?
            Rails.cache.fetch(key, expires_in: expiry_time, &block)
          else
            Rails.cache.fetch(key)
          end
        end

        def expiry_time
          5.minutes
        end

        def cache_namespace
          'rbCamdramApiResponses'
        end
      end
    end
  end
end
