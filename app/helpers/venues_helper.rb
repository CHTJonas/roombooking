module VenuesHelper
  def events_for(venue)
   start_date = (params[:start_date] ? Date.parse(params[:start_date]) : Date.today).beginning_of_week
   end_date = start_date + 6.days
   events = Array.new

   daily_bookings = venue.booking.where("repeat_until IS NULL").where(start_time: start_date..end_date).accessible_by(current_ability, :read)
   daily_bookings.to_a.each { |i| events << Event.create_from_booking(i) }

   repeat_bookings = venue.booking.where(repeat_until: start_date..end_date).accessible_by(current_ability, :read)
   repeat_bookings.to_a.each do |booking|
     for date in booking.start_time.to_date..booking.repeat_until do
       offset = date - booking.start_time.to_date
       events << Event.create_from_booking(booking, offset)
     end
   end

   return events
  end

  def event_time_range(event)
    event.start_time.strftime("%H:%M") + "—" + event.end_time.strftime("%H:%M")
  end

  def event_div_styles(event)
    top = event_div_top(event)
    height = event_div_height(event)
    "top:#{top}%;height:#{height}%;background-color:#00FF00"
  end

  def event_div_top(event)
    (event.start_time.hour - 8) * 6.25 + (event.start_time.min / 30) * 3.125
  end

  def event_div_height(event)
    (event.duration / 1800) * 3.125
  end
end
