# frozen_string_literal: true

module BookingsHelper
  def describe_repeat_pattern(repeat_mode, repeat_until)
    if repeat_mode.to_sym == :none
      return 'No'
    else
      return repeat_mode.to_s.capitalize + ' until ' + repeat_until.strftime("%A #{repeat_until.day.ordinalize} %b %Y")
    end
  end

  def purpose_of(booking)
    string = booking.purpose.humanize
    unless booking.camdram_model.nil?
      string << ' "' + link_to(booking.camdram_model.name, url_for(booking.camdram_model)) + '"'
    end
    string.html_safe
  end

  def british_date(date)
    return nil if date.nil?
    date.strftime("%d/%m/%Y")
  end

  def british_date_with_time(datetime)
    return nil if datetime.nil?
    datetime.strftime("%d/%m/%Y %R")
  end
end
