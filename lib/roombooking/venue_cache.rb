# frozen_string_literal: true

module Roombooking
  module VenueCache
    class << self
      def clear
        cache.clear
      end

      def add(room)
        cache.merge(room.camdram_venues)
      end

      def each(&block)
        cache.each(&block)
      end

      def regenerate
        puts ''
        puts ''
        puts ''
        puts 'Regenerating the Camdram venue cache...'
        puts ''
        puts ''
        puts ''
        clear
        Room.all.each do |room|
          add(room)
        end
      end

      private

      def cache
        @cache ||= Concurrent::Set.new
      end
    end
  end
end
