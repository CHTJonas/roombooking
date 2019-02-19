module Bookings
  class NotAuthorisedOnCamdramException < StandardError
    attr_reader :data
    def initialize(data)
      @data = data
    end
  end
end
