# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  admin_only :boolean          default(FALSE), not null
#

class Room < ApplicationRecord
  has_paper_trail
  strip_attributes only: [:name]

  has_many :bookings, dependent: :destroy
  has_and_belongs_to_many :camdram_venues

  validates :name, presence: true

  def currently_booked?
    current_booking.present?
  end

  def current_booking
    now = Time.zone.now
    get_booking_at(now)
  end

  def get_booking_at(date)
    query = bookings.find_by(repeat_mode: :none, start_time: Time.at(0)..date, end_time: date..DateTime::Infinity.new)
    return query unless query.nil?

    bookings.where(repeat_mode: :daily, start_time: Time.at(0)..date, repeat_until: date..DateTime::Infinity.new).each do |bkg|
      next unless bkg.start_time.seconds_since_midnight < date.seconds_since_midnight
      if bkg.end_time.seconds_since_midnight > date.seconds_since_midnight || bkg.end_time.seconds_since_midnight == 0
        return bkg
      end
    end
    bookings.where(repeat_mode: :weekly, start_time: Time.at(0)..date, repeat_until: date..DateTime::Infinity.new).each do |bkg|
      next unless bkg.start_time.wday == date.wday

      next unless bkg.start_time.seconds_since_midnight < date.seconds_since_midnight
      if bkg.end_time.seconds_since_midnight > date.seconds_since_midnight || bkg.end_time.seconds_since_midnight == 0
        return bkg
      end
    end
    nil
  end

  def events_in_range(start_date, end_date)
    Event.from_bookings(bookings.in_range(start_date, end_date))
  end
end
