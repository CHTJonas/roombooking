module VenuesHelper
  def event_time_range(event)
    event.start_time.strftime("%H:%M") + "—" + event.end_time.strftime("%H:%M")
  end

  def event_div_styles(event)
    top = event_div_top(event)
    height = event_div_height(event)
    colour = event.booking.css_colour
    "top:#{top}%;height:#{height}%;background-color:#{colour}"
  end

  def event_div_top(event)
    (event.start_time.hour - 8) * 6.25 + (event.start_time.min / 30) * 3.125
  end

  def event_div_height(event)
    (event.duration / 1800) * 3.125
  end
end
