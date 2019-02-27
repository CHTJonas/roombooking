# frozen_string_literal: true

class ShowEnumerationService < ApplicationService
  def perform
    list_of_shows = LinkedList::List.new
    Roombooking::CamdramAPI.with do |client|
      rooms = ApplicationSetting.instance.camdram_venues
      rooms.each do |room|
        shows =  client.get_venue(room).shows
        shows.each { |s| list_of_shows << s }
      end
    end
    list_of_shows.to_a.sort_by(&:name)
  end
end
