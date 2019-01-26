class CamdramShowsController < ApplicationController
  def show
    @camdram_show = CamdramShow.find(params[:id])
    # TODO
    # authorize! :read, @camdram_show
    @external_show = Roombooking::CamdramAPI.client.get_show(@camdram_show.camdram_id)
    @quota = [0, 0, 0] # [rehearsals, auditions, meetings]

    start_of_week = Time.now.beginning_of_week
    end_of_week = start_of_week + 1.week

    ordinary_bookings = Booking.where(repeat_mode: :none)
      .where(start_time: start_of_week..end_of_week)
      .where(camdram_model: @camdram_show)
    daily_repeat_bookings = Booking.where(repeat_mode: :daily)
      .where(start_time: Time.at(0)..end_of_week)
      .where(repeat_until: start_of_week..DateTime::Infinity.new)
      .where(camdram_model: @camdram_show)
    weekly_repeat_bookings = Booking.where(repeat_mode: :weekly)
      .where(start_time: Time.at(0)..end_of_week)
      .where(repeat_until: start_of_week..DateTime::Infinity.new)
      .where(camdram_model: @camdram_show)
    bookings = ordinary_bookings + daily_repeat_bookings + weekly_repeat_bookings

    bookings.each do |booking|
      if booking.purpose == 'rehearsal of'
        @quota[0] += 1
      elsif booking.purpose == 'audition for'
        @quota[1] += 1
      elsif booking.purpose == 'meeting for'
        @quota[2] += 1
      end
    end
  end
end
