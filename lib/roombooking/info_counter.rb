# frozen_string_literal: true

module Roombooking
  class InfoCounter
    def initialize(key)
      ns = Roombooking::InfoCounter.key_namespace
      @cache_key = "#{ns}/#{key}".downcase.split.join('-').freeze
    end

    def count
      Rails.cache.fetch(@cache_key) { 0 }
    end

    def increment
      Rails.cache.write(@cache_key, count + 1)
    end

    def to_s
      count.to_s
    end

    def self.poke(key)
      unless Rails::Info.properties.value_for(key)
        Rails::Info.property(key, Roombooking::InfoCounter.new(key))
      end
      Rails::Info.properties.value_for(key).increment
    end

    def self.key_namespace
      "info_counters".freeze
    end
  end
end
