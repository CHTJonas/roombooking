module SearchHelper
  def full_written_date(date)
    date.strftime("%H:%M on %a #{date.day.ordinalize} %b %Y")
  end
end
