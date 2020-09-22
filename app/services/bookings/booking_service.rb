# frozen_string_literal: true

module Bookings
  class BookingService < ApplicationService
    attr_reader :booking, :shows, :societies

    def initialize(params, user, current_imposter, camdram_entity_service)
      @params = params
      @user = user
      @current_imposter = current_imposter
      @camdram_entity_service = camdram_entity_service
    end

    private

    def booking_params
      @params.require(:booking).permit(:name, :notes, :start_time, :length, :room_id, :attendees_text, :purpose, :repeat_mode, :repeat_until, :excluded_repeat_dates)
    end

    def populate_camdram_entities
      @shows = @camdram_entity_service.shows
      @societies = @camdram_entity_service.societies
    end

    def setup_booking_purpose
      unless @booking.purpose.nil?
        if Booking.purposes_with_none.include?(@booking.purpose.to_sym)
          @booking.camdram_model = nil
        else
          id = @params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
          return unless id.present?
          if Booking.purposes_with_shows.include?(@booking.purpose.to_sym)
            @booking.camdram_model = CamdramShow.find(id)
          elsif Booking.purposes_with_societies.include?(@booking.purpose.to_sym)
            @booking.camdram_model = CamdramSociety.find(id)
          else
            @booking.camdram_model = nil
          end
        end
      end
    end

    def booking_authorised_against_camdram?
      # We can't authorise if there's no purpose given, but this get's caught by the Booking model validation.
      return true if @booking.purpose.nil?
      if Booking.admin_purposes.include?(@booking.purpose.to_sym)
        # Admins can do anything.
        return @user.admin?
      end
      if Booking.purposes_with_none.include?(@booking.purpose.to_sym)
        # Nothing to authorise!
        return true
      end
      # We can't authorise if there's no show/society selected, but this get's caught by the Booking model validation.
      id = @params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
      return true if id.nil?
      if Booking.purposes_with_shows.include?(@booking.purpose.to_sym)
        return @user.camdram_shows.include? @booking.camdram_model
      elsif Booking.purposes_with_societies.include?(@booking.purpose.to_sym)
        return @user.camdram_societies.include? @booking.camdram_model
      else
        return false
      end
    end
  end
end
