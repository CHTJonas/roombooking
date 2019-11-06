# frozen_string_literal: true

module DateTimeHelper
  def british_date(date)
    return nil if date.nil?
    date.strftime("%d/%m/%Y")
  end

  def british_date_and_time(datetime)
    return nil if datetime.nil?
    datetime.strftime("%d/%m/%Y %R")
  end
end
