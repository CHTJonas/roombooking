# frozen_string_literal: true

module RoomsHelper
  def event_time_range(event)
    event.start_time.strftime('%H:%M') + '—' + event.end_time.strftime('%H:%M')
  end

  def event_div_styles(event)
    top = event_div_top(event)
    height = event_div_height(event)
    "top: #{top}%; height: #{height}%;"
  end

  def event_div_top(event)
    (event.start_time.hour - 8) * 6.25 + (event.start_time.min / 15) * 1.5625
  end

  def event_div_height(event)
    (event.duration / 1800) * 3.125
  end
end
