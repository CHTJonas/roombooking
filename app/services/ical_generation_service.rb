# frozen_string_literal: true

class IcalGenerationService < ApplicationService
  def initialize(bookings, cache_key)
    @bookings = bookings
    @cache_key = cache_key
  end

  def perform(refresh_cache: false)
    Rails.cache.fetch("ical/#{@cache_key}", expires_in: nil, force: refresh_cache) do
      @bookings.each do |booking|
        calendar.event do |e|
          e.dtstart     = Icalendar::Values::DateTime.new(booking.start_time, 'tzid' => tzid)
          e.dtend       = Icalendar::Values::DateTime.new(booking.end_time, 'tzid' => tzid)
          unless booking.repeat_mode == 'none'
            e.rrule     = "FREQ=#{booking.repeat_mode};UNTIL=#{(booking.repeat_until + 1.day).strftime("%Y%m%d")}"
          end
          e.summary     = booking.name
          e.description = "Purpose: #{booking.purpose_string}\n\n#{booking.notes}"
          e.location    = booking.room.name
          e.organizer   = booking.user.name
          e.url         = Roombooking::UrlGenerator.url_for(booking)
        end
      end
      calendar.publish
      calendar.to_ical
    end
  end

  private

  def tzid
    @@tzid ||= 'Europe/London'
  end

  def calendar
    @calendar ||= (
      cal = Icalendar::Calendar.new
      cal.timezone do |t|
        t.tzid = tzid
        t.daylight do |d|
          d.tzoffsetfrom = '+0000'
          d.tzoffsetto   = '+0100'
          d.tzname       = 'BST'
          d.dtstart      = '19810329T010000'
          d.rrule        = 'FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU'
        end
        t.standard do |s|
          s.tzoffsetfrom = '+0100'
          s.tzoffsetto   = '+0000'
          s.tzname       = 'GMT'
          s.dtstart      = '19961027T020000'
          s.rrule        = 'FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU'
        end
      end
      cal
    )
  end
end
