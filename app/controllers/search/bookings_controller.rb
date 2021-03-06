# frozen_string_literal: true

module Search
  class BookingsController < ApplicationController
    def search
      query = params['q']
      page = params['page']
      @bookings = Booking.includes(:room)
                         .order(start_time: :desc)
                         .accessible_by(current_ability, :read)
                         .search_by_name_and_notes(query)
                         .page(page)
    end
  end
end
