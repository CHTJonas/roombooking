module Bookings
  class NotAuthorisedOnCamdramException < StandardError
    attr_reader :booking, :shows, :societies

    def initialize(booking, shows, societies)
      @booking = booking
      @shows = shows
      @societies = societies
    end
  end
end
