module BookingsHelper
  def describe_repeat_pattern(repeat_mode, repeat_until)
    if repeat_mode.to_sym == :none
      return 'No'
    else
      return repeat_mode.to_s.capitalize + ' until ' + repeat_until.strftime("%A #{repeat_until.day.ordinalize} %b %Y")
    end
  end
end
