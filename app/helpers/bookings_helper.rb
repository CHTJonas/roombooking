# frozen_string_literal: true

module BookingsHelper
  def describe_repeat_pattern(repeat_mode, repeat_until)
    if repeat_mode.to_sym == :none
      'No'
    else
      repeat_mode.to_s.capitalize + ' until ' + repeat_until.strftime("%A #{repeat_until.day.ordinalize} %b %Y")
    end
  end

  def purpose_of(booking)
    string = booking.purpose.humanize
    unless booking.camdram_model.nil?
      string += ' "' + link_to(booking.camdram_model.name, url_for(booking.camdram_model)) + '"'
    end
    string.html_safe
  end
end
