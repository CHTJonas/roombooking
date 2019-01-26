class CamdramSocietiesController < ApplicationController
  def show
    @camdram_society = CamdramSociety.find(params[:id])
    # TODO
    # authorize! :read, @camdram_society
    @external_society = Roombooking::CamdramAPI.client.get_society(@camdram_society.camdram_id)
    @quota = 0

    start_of_week = Time.now.beginning_of_week
    end_of_week = start_of_week + 1.week

    ordinary_bookings = Booking.where(repeat_mode: :none)
      .where(start_time: start_of_week..end_of_week)
      .where(camdram_model: @camdram_society)
    daily_repeat_bookings = Booking.where(repeat_mode: :daily)
      .where(start_time: Time.at(0)..end_of_week)
      .where(repeat_until: start_of_week..DateTime::Infinity.new)
      .where(camdram_model: @camdram_society)
    weekly_repeat_bookings = Booking.where(repeat_mode: :weekly)
      .where(start_time: Time.at(0)..end_of_week)
      .where(repeat_until: start_of_week..DateTime::Infinity.new)
      .where(camdram_model: @camdram_society)
    bookings = ordinary_bookings + daily_repeat_bookings + weekly_repeat_bookings

    bookings.each do |booking|
      if booking.purpose == 'meeting of'
        @quota += 1
      end
    end
  end
end
