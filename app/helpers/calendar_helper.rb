module CalendarHelper
  def written_date_with_month(date)
    date.strftime("%a #{date.day.ordinalize} %b")
  end

  def written_date(date)
    date.strftime("%A #{date.day.ordinalize}")
  end
end
