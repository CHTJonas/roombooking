class Venue < ApplicationRecord
  has_many :booking

  validates :name, presence: true

  def currently_booked?
    !self.current_booking.nil?
  end

  def current_booking
    now = DateTime.now
    query = self.booking.find_by(approved: true, repeat_mode: :none, start_time: Time.at(0)..now, end_time: now..DateTime::Infinity.new)
    return query unless query.nil?
    self.booking.where(approved: true, repeat_mode: :daily, start_time: Time.at(0)..now, repeat_until: now..DateTime::Infinity.new).each do |booking|
      if bkg.start_time.seconds_since_midnight < now.seconds_since_midnight
        if bkg.end_time.seconds_since_midnight > now.seconds_since_midnight
          return bkg
        end
      end
    end
    self.booking.where(approved: true, repeat_mode: :weekly, start_time: Time.at(0)..now, repeat_until: now..DateTime::Infinity.new).each do |booking|
      if bkg.start_time.wday = now.wday
        if bkg.start_time.seconds_since_midnight < now.seconds_since_midnight
          if bkg.end_time.seconds_since_midnight > now.seconds_since_midnight
            return bkg
          end
        end
      end
    end
    nil
  end
end
