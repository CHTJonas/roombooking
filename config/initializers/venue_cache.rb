# frozen_string_literal: true

require "#{Rails.root}/lib/roombooking/venue_cache.rb"
Roombooking::VenueCache.regenerate
