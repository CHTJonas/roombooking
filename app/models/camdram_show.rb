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

  # Creates a CamdramShow model from a numeric Camdram ID.
  def self.create_from_id(id)
    create_from_id_and_name(id, nil)
  end

  # Creates a CamdramShow model from a numeric Camdram ID and name.
  def self.create_from_id_and_name(id, name)
    create! do |roombooking_show|
      roombooking_show.camdram_id = id
      roombooking_show.max_rehearsals = 12
      roombooking_show.max_auditions = 10
      roombooking_show.max_meetings = 4
      roombooking_show.active = true
      roombooking_show.memoized_name = name if name.present?
    end
  end

  # Abstraction to allow vallidation of new bookings. Returns an array that
  # counts the show's currently used quota for the week beginning on the
  # given date.
  def calculate_weekly_quota(start_of_week, bookings)
    end_of_week = start_of_week + 7.days
    quota = [0, 0, 0] # [rehearsals, auditions, meetings]
    bookings.each do |booking|
      booking.repeat_iterator do |st, _|
        break if st >= end_of_week
        if st >= start_of_week
          quota_increase = booking.duration / 60 / 60
          if booking.purpose == 'rehearsal_for'
            quota[0] += quota_increase
          elsif booking.purpose == 'audition_for'
            quota[1] += quota_increase
          elsif booking.purpose == 'meeting_for'
            quota[2] += quota_increase
          end
        end
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
          if performance_time.hour == 19 && performance_time.minutes == 45
            # Mainshow
            get_in_start_time = performance.start_at.beginning_of_week + 8.hours
            get_in_end_time = performance.start_at.beginning_of_week + 24.hours
            performance_start_time = performance.start_at.beginning_of_day + 18.hours
            performance_end_time = performance.start_at.beginning_of_day + 22.hours + 30.minutes
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Mainshow Get-in', start_time: get_in_start_time, end_time: get_in_end_time,
              repeat_until: performance.start_at.beginning_of_week.to_date + 1.day, repeat_mode: :daily,
              purpose: :get_in_for, room_id: 1, user: user, camdram_model: self)
            Booking.create!(name: 'Mainshow Dressing Room', start_time: get_in_start_time, end_time: get_in_end_time,
              repeat_until: performance.start_at.beginning_of_week.to_date + 1.day, repeat_mode: :daily,
              purpose: :get_in_for, room_id: 4, user: user, camdram_model: self)
            Booking.create!(name: 'Mainshow Get-in', start_time: get_in_start_time + 2.days,
              end_time: get_in_start_time + 2.days + 10.hours, purpose: :get_in_for, room_id: 1,
              user: user, camdram_model: self)
            Booking.create!(name: 'Mainshow Dressing Room', start_time: get_in_start_time + 2.days,
              end_time: get_in_start_time + 2.days + 10.hours, purpose: :get_in_for, room_id: 4,
              user: user, camdram_model: self)
            Booking.create!(name: 'Mainshow', start_time: performance_start_time, end_time: performance_end_time,
              repeat_until: repeat_until, repeat_mode: repeat_mode, purpose: :performance_of,
              room_id: 1, user: user, camdram_model: self)
            Booking.create!(name: 'Mainshow Dressing Room', start_time: performance_start_time,
              end_time: performance_end_time.beginning_of_day + 24.hours, repeat_until: repeat_until,
              repeat_mode: repeat_mode, purpose: :performance_of, room_id: 4, user: user, camdram_model: self)
            Booking.create!(name: 'Unavailable for use', start_time: performance_start_time + 1.hour,
              end_time: performance_end_time, repeat_until: repeat_until, repeat_mode: repeat_mode,
              purpose: :theatre_closed, room_id: 2, user: user,
              notes: 'Please email production@adctheatre.com to book during these hours.')
          elsif performance_time.hour == 23 && performance_time.minutes == 0
            # Lateshow
            get_in_start_time = performance.start_at.beginning_of_week + 3.days + 8.hours
            get_in_end_time = performance.start_at.beginning_of_week + 3.days + 18.hours
            performance_start_time = performance.start_at.beginning_of_day + 22.hours + 30.minutes
            performance_end_time = performance.start_at.beginning_of_day + 24.hours
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Lateshow Get-in', start_time: get_in_start_time, end_time: get_in_end_time,
              purpose: :get_in_for, room_id: 1, user: user, camdram_model: self)
            Booking.create!(name: 'Lateshow Dressing Room', start_time: get_in_start_time,
              end_time: performance.start_at.beginning_of_day + 21.hours, purpose: :get_in_for, room_id: 3,
              user: user, camdram_model: self)
            Booking.create!(name: 'Lateshow', start_time: performance_start_time, end_time: performance_end_time,
              repeat_until: repeat_until, repeat_mode: repeat_mode, purpose: :performance_of,
              room_id: 1, user: user, camdram_model: self)
            Booking.create!(name: 'Lateshow Dressing Room', start_time: performance.start_at.beginning_of_day + 21.hours,
              end_time: performance.start_at.beginning_of_day + 24.hours, repeat_until: repeat_until,
              repeat_mode: repeat_mode, purpose: :performance_of, room_id: 3, user: user, camdram_model: self)
            Booking.create!(name: 'Unavailable for use', start_time: performance_start_time,
              end_time: performance_end_time, repeat_until: repeat_until, repeat_mode: repeat_mode,
              purpose: :theatre_closed, room_id: 2, user: user,
              notes: 'Please email production@adctheatre.com to book during these hours.')
          elsif performance_time.hour == 14 && performance_time.minutes == 30
            # Matinee
            performance_start_time = performance.start_at.beginning_of_day + 13.hours
            performance_end_time = performance.start_at.beginning_of_day + 18.hours
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Matinee Dressing Room', start_time: performance_start_time,
              end_time: performance_end_time, repeat_until: repeat_until, repeat_mode: repeat_mode,
              purpose: :performance_of, room_id: 4, user: user, camdram_model: self)
            Booking.create!(name: 'Mainshow Matinee', start_time: performance_start_time,
              end_time: performance_end_time, repeat_until: repeat_until, repeat_mode: repeat_mode,
              purpose: :performance_of, room_id: 1, user: user, camdram_model: self)
            Booking.create!(name: 'Unavailable for use', start_time: performance_start_time + 30.minutes,
              end_time: performance_end_time, repeat_until: repeat_until, repeat_mode: repeat_mode,
              purpose: :theatre_closed, room_id: 2, user: user,
              notes: 'Please email production@adctheatre.com to book during these hours.')
          else
            Sentry.capture_exception(NotImplementedError.new)
            send_not_implemented_email(user, performance)
          end
        elsif performance.venue.slug == 'corpus-playroom'
          if performance_time.hour == 19 && performance_time.minutes == 0
            # Mainshow
            start_time = performance.start_at.beginning_of_day + 18.hours
            end_time = performance.start_at.beginning_of_day + 21.hours
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Mainshow', start_time: start_time, end_time: end_time,
              repeat_until: repeat_until, repeat_mode: repeat_mode, purpose: :performance_of,
              room_id: 6, user: user, camdram_model: self)
          elsif performance_time.hour == 21 && performance_time.minutes == 30
            # Lateshow
            start_time = performance.start_at.beginning_of_day + 21.hours
            end_time = performance.start_at.beginning_of_day + 24.hours
            repeat_until = performance.repeat_until
            repeat_mode = repeat_until.nil? ? :none : :daily
            Booking.create!(name: 'Lateshow', start_time: start_time, end_time: end_time,
              repeat_until: repeat_until, repeat_mode: repeat_mode, purpose: :performance_of,
              room_id: 6, user: user, camdram_model: self)
          else
            Sentry.capture_exception(NotImplementedError.new)
            send_not_implemented_email(user, performance)
          end
        end
      end
    end
  end

  private

  def send_not_implemented_email(user, performance)
    ApplicationMailer.new.mail(
      to: user.email,
      bcc: 'charlie@charliejonas.co.uk',
      subject: '[Room Booking System] Block Booking Failure',
      body: <<~END
        Hello,

        This is an automated email from the ADC Room Booking System. Please do
        not reply.

        The following show was imported successfully, but could not be
        recognised as a regular Mainshow or Lateshow. To be safe, it therefore
        did not have its block bookings created automatically.

        ====================
        #{camdram_object.name}
        (Camdram ID #{camdram_object.id})
        #{performance.start_at.to_s(:rfc822)} until #{performance.repeat_until.to_s(:rfc822)}
        #{performance.venue.name}
        ====================

        Please manually make bookings of the Stage, Dressing Rooms and Larkum
        Studio as necessary for the show's performance, get-in and rehearsal
        times.

        Kind regards,

        Your friendly Room Booking Robots
      END
    ).deliver
  end
end
