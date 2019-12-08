# frozen_string_literal: true

class Camdram::Performance
  def end_at
    if repeat_until
      start_at + (repeat_until - start_at.to_date)
    else
      start_at
    end
  end
end
