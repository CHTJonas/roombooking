# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  camdram_venues :string           is an Array
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Room < ApplicationRecord
  has_paper_trail

  has_many :booking, dependent: :destroy
  has_many :approved_bookings, -> { where(approved: true) }, class_name: 'Booking'

  validates :name, presence: true

  after_commit { Roombooking::VenueCache.regenerate }

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

  def events_in_range(start_date, end_date)
    Event.from_bookings approved_bookings.in_range(start_date, end_date)
  end
end
