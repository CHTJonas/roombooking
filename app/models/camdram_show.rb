# frozen_string_literal: true

# == Schema Information
#
# Table name: camdram_shows
#
#  id             :bigint           not null, primary key
#  camdram_id     :bigint           not null
#  max_rehearsals :integer          default(0), not null
#  max_auditions  :integer          default(0), not null
#  max_meetings   :integer          default(0), not null
#  active         :boolean          default(FALSE), not null
#  dormant        :boolean          default(FALSE), not null
#  slack_webhook  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  memoized_name  :string
#

class CamdramShow < ApplicationRecord
  include CamdramInteroperability
  include CamdramBookingHandling
  include DataPreservation

  has_paper_trail
  strip_attributes only: [:slack_webhook]
  uses_camdram_client_method :get_show

  has_and_belongs_to_many :users

  validates :max_rehearsals, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :max_auditions, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :max_meetings, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  # Creates a CamdramShow model from a numeric Camdram id.
  def self.create_from_id(id)
    create! do |roombooking_show|
      roombooking_show.camdram_id = id
      roombooking_show.max_rehearsals = 12
      roombooking_show.max_auditions = 10
      roombooking_show.max_meetings = 4
      roombooking_show.active = true
    end
  end

  # Abstraction to allow vallidation of new bookings. Returns an array that
  # counts the show's currently used quota for the week beginning on the
  # given date.
  def calculate_weekly_quota(start_of_week, bookings)
    quota = [0, 0, 0] # [rehearsals, auditions, meetings]
    bookings.each do |booking|
      occurrences = 1
      if booking.repeat_mode == 'daily'
        start_repeating_from = start_of_week < booking.start_time ? booking.start_time : start_of_week
        occurrences = (start_repeating_from.to_date..booking.repeat_until.to_date).count
      end
      quota_increase = occurrences * booking.duration / 60 / 60
      if booking.purpose == 'rehearsal_for'
        quota[0] += quota_increase
      elsif booking.purpose == 'audition_for'
        quota[1] += quota_increase
      elsif booking.purpose == 'meeting_for'
        quota[2] += quota_increase
      end
    end
    quota
  end

  # Returns true if the show has exceeded any of the given quotas,
  # false otherwise.
  def exceeded_weekly_quota?(quota)
    quota[0] > max_rehearsals ||
      quota[1] > max_auditions ||
      quota[2] > max_meetings
  end

  def block_out_bookings(user)
    venue_ids = CamdramVenue.all.map(&:camdram_id)
    performances = camdram_object.performances.select do |p|
      p.venue && venue_ids.include?(p.venue.id)
    end
    # Wrap in a single transaction so that we either make all the block
    # bookings successfully, or none at all. Be sure to watch out for
    # UTC/DST bugs here! Internally, Camdram works in UTC everywhere.
    ActiveRecord::Base.transaction do
      performances.each do |performance|
        performance_time = performance.start_at.in_time_zone('London')
        if performance.venue.slug == 'adc-theatre'
          if performance_time.hour == 19
            # Mainshow
            start_time = performance.start_at.beginning_of_day + 18.hours
            end_time = performance.start_at.beginning_of_day + 22.hours + 30.minutes
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Mainshow', start_time: start_time, end_time: end_time,
                            repeat_until: repeat_until, repeat_mode: repeat_mode, purpose: :performance_of,
                            room_id: 1, user: user, camdram_model: self)
          elsif performance_time.hour == 23
            # Lateshow
            start_time = performance.start_at.beginning_of_day + 22.hours + 30.minutes
            end_time = performance.start_at.beginning_of_day + 24.hours
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Lateshow', start_time: start_time, end_time: end_time,
                            repeat_until: repeat_until, repeat_mode: repeat_mode, purpose: :performance_of,
                            room_id: 1, user: user, camdram_model: self)
          elsif performance_time.hour == 14
            # Matinee
            start_time = performance.start_at.beginning_of_day + 13.hours
            end_time = performance.start_at.beginning_of_day + 18.hours
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Matinee', start_time: start_time, end_time: end_time,
                            repeat_until: repeat_until, repeat_mode: repeat_mode, purpose: :performance_of,
                            room_id: 1, user: user, camdram_model: self)
          end
        elsif performance.venue.slug == 'corpus-playroom'
          if performance_time.hour == 19
            # Mainshow
            start_time = performance.start_at.beginning_of_day + 18.hours
            end_time = performance.start_at.beginning_of_day + 21.hours
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Mainshow', start_time: start_time, end_time: end_time,
                            repeat_until: repeat_until, repeat_mode: repeat_mode, purpose: :performance_of,
                            room_id: 6, user: user, camdram_model: self)
          elsif performance_time.hour == 21
            # Lateshow
            start_time = performance.start_at.beginning_of_day + 21.hours
            end_time = performance.start_at.beginning_of_day + 24.hours
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Lateshow', start_time: start_time, end_time: end_time,
                            repeat_until: repeat_until, repeat_mode: repeat_mode, purpose: :performance_of,
                            room_id: 6, user: user, camdram_model: self)
          end
        end
      end
    end
  end
end
