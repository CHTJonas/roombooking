# frozen_string_literal: true

class ShowEnumerationService < ApplicationService
  def perform
    list_of_shows = LinkedList::List.new
    Roombooking::CamdramApi.with do |client|
      CamdramVenue.find_each(batch_size: 10) do |camdram_venue|
        shows = client.get_venue(camdram_venue.camdram_id).shows
        shows.each { |s| list_of_shows << s.make_orphan }
      end
    end
    list_of_shows.to_a.sort_by(&:name)
  end
end
