module RoomsHelper
  def event_time_range(event)
    event.start_time.strftime("%H:%M") + "—" + event.end_time.strftime("%H:%M")
  end

  def event_div_styles(event)
    top = event_div_top(event)
    height = event_div_height(event)
    colour = colour_of(event.booking)
    "top:#{top}%;height:#{height}%;background-color:#{colour}"
  end

  def event_div_top(event)
    (event.start_time.hour - 8) * 6.25 + (event.start_time.min / 30) * 3.125
  end

  def event_div_height(event)
    (event.duration / 1800) * 3.125
  end

  # Returns the CSS colour of the booking as determined by the booking's type.
  def colour_of(booking)
    case booking.purpose.to_sym
    when :audition_for
      "\#FFFF00"
    when :meeting_for
      "\#00FFAA"
    when :meeting_of
      "\#00DDFF"
    when :performance_of
      "\#FF00FF"
    when :rehearsal_for
      "\#00FF00"
    when :get_in_for
      "\#FFAAAA"
    when :theatre_closed
      "\#FF0000"
    when :training
      "\#BFBFBF"
    else
      "\#888888"
    end
  end
end
