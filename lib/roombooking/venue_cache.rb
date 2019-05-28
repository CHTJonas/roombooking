# frozen_string_literal: true

module Roombooking
  module VenueCache
    class << self
      def each(&block)
        venues.each(&block)
      end

      def contains?(o)
        venues.include?(o)
      end

      def regenerate
        venues(force: true)
      end

      private

      def venues(force: false)
        Rails.cache.fetch(cache_key, force: force) do
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
