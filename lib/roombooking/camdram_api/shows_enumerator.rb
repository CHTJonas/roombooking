module Roombooking
  module CamdramAPI
    module ShowsEnumerator
      class << self
        def retrieve
          list_of_shows = LinkedList::List.new
          Roombooking::CamdramAPI.with do |client|
            rooms = ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar', 'corpus-playroom']
            rooms.each do |room|
              shows =  client.get_venue(room).shows
              shows.each { |s| list_of_shows << s }
            end
          end
          list_of_shows.to_a.sort_by(&:name)
        end
      end
    end
  end
end
