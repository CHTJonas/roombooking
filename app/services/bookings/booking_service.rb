module Bookings
  class BookingService < ApplicationService
    attr_reader :booking, :shows, :societies

    def initialize(params, user, impersonator)
      @params = params
      @user = user
      @impersonator = impersonator
    end

    private

    def booking_params
      if @user.admin?
        @params.require(:booking).permit(:name, :notes, :start_time, :length, :room_id, :purpose, :repeat_mode, :repeat_until, :approved)
      else
        @params.require(:booking).permit(:name, :notes, :start_time, :length, :room_id, :purpose, :repeat_mode, :repeat_until)
      end
    end

    def populate_data_from_camdram
      @shows, @societies = CamdramEntitiesService.get_authorised(@user, @impersonator)
    end

    def setup_booking_purpose
      unless @booking.purpose.nil?
        if Booking.purposes_with_none.find_index(@booking.purpose.to_sym)
          @booking.camdram_model = nil
        else
          id = @params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
          return unless id.present?
          if Booking.purposes_with_shows.find_index(@booking.purpose.to_sym)
            @booking.camdram_model = CamdramShow.find(id)
          elsif Booking.purposes_with_societies.find_index(@booking.purpose.to_sym)
            @booking.camdram_model = CamdramSociety.find(id)
          else
            @booking.camdram_model = nil
          end
        end
      end
    end

    def booking_authorise_against_camdram?
      # We can't authorise if there's no purpose given, but this get's caught by the Booking model validation.
      return true if @booking.purpose.nil?
      if Booking.admin_purposes.find_index(@booking.purpose.to_sym)
        # Admins can do anything.
        return @user.admin?
      end
      if Booking.purposes_with_none.find_index(@booking.purpose.to_sym)
        # Nothing to authorise!
        return true
      end
      # We can't authorise if there's no show/society selected, but this get's caught by the Booking model validation.
      id = @params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
      return true if id.nil?
      if Booking.purposes_with_shows.find_index(@booking.purpose.to_sym)
        return @user.authorised_camdram_shows.include? @booking.camdram_model
      elsif Booking.purposes_with_societies.find_index(@booking.purpose.to_sym)
        return @user.authorised_camdram_societies.include? @booking.camdram_model
      else
        return false
      end
    end
  end
end
