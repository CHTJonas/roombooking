# == Schema Information
#
# Table name: rooms
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Room < ApplicationRecord
  has_many :booking, dependent: :delete_all

  validates :name, presence: true

  def currently_booked?
    current_booking.present?
  end

  def current_booking
    now = DateTime.now
    get_booking_at(now)
  end

  def get_booking_at(date)
    query = self.booking.find_by(approved: true, repeat_mode: :none, start_time: Time.at(0)..date, end_time: date..DateTime::Infinity.new)
    return query unless query.nil?
    self.booking.where(approved: true, repeat_mode: :daily, start_time: Time.at(0)..date, repeat_until: date..DateTime::Infinity.new).each do |bkg|
      if bkg.start_time.seconds_since_midnight < date.seconds_since_midnight
        if bkg.end_time.seconds_since_midnight > date.seconds_since_midnight
          return bkg
        end
      end
    end
    self.booking.where(approved: true, repeat_mode: :weekly, start_time: Time.at(0)..date, repeat_until: date..DateTime::Infinity.new).each do |bkg|
      if bkg.start_time.wday == date.wday
        if bkg.start_time.seconds_since_midnight < date.seconds_since_midnight
          if bkg.end_time.seconds_since_midnight > date.seconds_since_midnight
            return bkg
          end
        end
      end
    end
    nil
  end
end
