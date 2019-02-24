module Bookings
  class NotAuthorisedOnCamdramException < StandardError
    attr_reader :booking
    def initialize(booking)
      @booking = booking
    end
  end
end
