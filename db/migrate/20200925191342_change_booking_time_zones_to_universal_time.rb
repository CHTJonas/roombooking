class ChangeBookingTimeZonesToUniversalTime < ActiveRecord::Migration[6.0]
  def up
    Booking.all.each do |booking|
      booking.start_time = booking.start_time.in_time_zone("London").asctime.in_time_zone("UTC")
      booking.end_time = booking.end_time.in_time_zone("London").asctime.in_time_zone("UTC")
      booking.save(validate: false)
    end
  end

  def down
    Booking.all.each do |booking|
      booking.start_time = booking.start_time.in_time_zone("UTC").asctime.in_time_zone("London")
      booking.end_time = booking.end_time.in_time_zone("UTC").asctime.in_time_zone("London")
      booking.save(validate: false)
    end
  end
end
