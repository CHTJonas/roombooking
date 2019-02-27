# frozen_string_literal: true

module Admin
  class ShowRetrievalService < ApplicationService
    def perform
      camdram_shows = ShowEnumerationService.perform
      show_tuples = Array.new(camdram_shows.length)
      i = 0
      camdram_shows.each do |camdram_show|
        roombooking_show = CamdramShow.find_from_camdram(camdram_show)
        if roombooking_show.try(:dormant?)
          # Show are only marked dormant at the start/end of a term, in which
          # case they should be absent from the response from the Camdram API
          # (since they're no longer upcoming). Hence this operation won't be
          # called very often is so shouldn't be too computationally expensive.
          show_tuples.delete_at(i)
        else
          show_tuples[i] = [camdram_show, roombooking_show]
          i += 1
        end
      end
      show_tuples
    end
  end
end
