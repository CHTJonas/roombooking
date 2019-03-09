# frozen_string_literal: true

module Roombooking
  module VenueCache
    class << self
      def each(&block)
        cache.each(&block)
      end

      def contains?(o)
        cache.include?(o)
      end

      def regenerate
        @cache = nil
        cache
        nil
      end

      private

      def cache
        @cache ||= (
          set = Concurrent::Set.new
          Room.all.each do |room|
            set.merge(room.camdram_venues) if room.camdram_venues
          end
          set
        )
      end
    end
  end
end
