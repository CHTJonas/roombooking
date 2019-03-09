# frozen_string_literal: true

module Roombooking
  module VenueCache
    class << self
      def each(&block)
        venues.each(&block)
        nil
      end

      def contains?(o)
        venues.include?(o)
      end

      def regenerate
        Rails.cache.write(cache_key, set_of_venues.to_a)
        nil
      end

      private

      def venues
        Rails.cache.fetch(cache_key) do
          set_of_venues.to_a
        end
      end

      def set_of_venues
        set = Set.new
        Room.all.each do |room|
          set.merge(room.camdram_venues) if room.camdram_venues
        end
        set
      end

      def cache_key
        'rbCamdramVenues'
      end
    end
  end
end
