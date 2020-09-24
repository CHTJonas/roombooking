# frozen_string_literal: true
# == Schema Information
#
# Table name: bookings
#
#  id                    :bigint           not null, primary key
#  name                  :string           not null
#  notes                 :text
#  start_time            :datetime         not null
#  end_time              :datetime         not null
#  repeat_until          :date
#  repeat_mode           :integer          default("none"), not null
#  purpose               :integer          not null
#  room_id               :bigint           not null
#  user_id               :bigint           not null
#  camdram_model_type    :string
#  camdram_model_id      :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  excluded_repeat_dates :string
#

class Booking < ApplicationRecord
  has_paper_trail
  strip_attributes only: [:name, :notes, :excluded_repeat_dates]
  paginates_per 9
  include PgSearch::Model
  pg_search_scope :search_by_name_and_notes, against: { name: 'A', notes: 'B' },
    ignoring: :accents, using: { tsearch: { prefix: true, dictionary: 'english' },
    dmetaphone: { any_word: true }, trigram: { only: [:name] } }

  def self.admin_purposes
    [ :performance_of, :get_in_for, :theatre_closed, :training, :other ]
  end
  def self.purposes_with_shows
    [ :audition_for, :meeting_for, :performance_of, :rehearsal_for, :get_in_for ]
  end
  def self.purposes_with_societies
    [ :meeting_of ]
  end
  def self.purposes_with_none
    [ :theatre_closed, :training, :other ]
  end

  enum repeat_mode: [ :none, :daily, :weekly ], _prefix: :repeat_mode
  enum purpose: purposes_with_shows + purposes_with_societies + purposes_with_none, _prefix: :purpose

  belongs_to :room, touch: true
  belongs_to :user
  belongs_to :camdram_model, polymorphic: true, required: false
  has_and_belongs_to_many :attendees

  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :duration, numericality: {
    greater_than_or_equal_to: 1800,
    message: 'must be at least 30 minutes'
  }
  validates :purpose, presence: true

  validate :cannot_be_in_the_past
  validate :cannot_be_too_far_in_future
  validate :cannot_be_during_quiet_hours
  validate :must_end_on_same_day
  validate :must_fill_half_hour_slot
  validate :must_not_overlap
  validate :repeat_until_must_be_valid
  validate :excluded_repeat_dates_must_be_valid
  validate :camdram_model_must_be_valid
  validate :must_not_exceed_quota
  validate :room_must_allow_camdram_venue
  validate :name_must_be_descriptive
  validate :attendees_must_conform
  validate :user_must_be_allowed_to_book_room

  # Scope all bookings that occur between the two given dates. Note that
  # end_date should be midnight of the day after the last day you'd like
  # to include in the query.
  scope :in_range, ->(start_date, end_date) {
    ordinary_in_range(start_date, end_date) +
      daily_repeat_in_range(start_date, end_date) +
      weekly_repeat_in_range(start_date, end_date)
  }

  # Scope non-repeating bookings that occur between the two given dates.
  # Note that end_date should be midnight of the day after the last day
  # you'd like to include in the query.
  scope :ordinary_in_range, ->(start_date, end_date) {
    where(repeat_mode: :none).where(start_time: start_date..end_date)
  }

  # Scope bookings that repeat daily and which occur between the two given
  # dates. Note that end_date should be midnight of the day after the last
  # day you'd like to include in the query.
  scope :daily_repeat_in_range, ->(start_date, end_date) {
    where(repeat_mode: :daily)
    .where(start_time: Time.at(0)..end_date)
    .where(repeat_until: start_date..DateTime::Infinity.new)
  }

  # Scope bookings that repeat weekly and which occur between the two given
  # dates. Note that end_date should be midnight of the day after the last
  # day you'd like to include in the query.
  scope :weekly_repeat_in_range, ->(start_date, end_date) {
    where(repeat_mode: :weekly)
    .where(start_time: Time.at(0)..end_date)
    .where(repeat_until: start_date..DateTime::Infinity.new)
    .where(%{ date_part('dow', start_time) IN (
      SELECT date_part('dow', d) FROM (
        SELECT generate_series(:start, :end, '1 day'::interval) AS d
      ) AS _)
    }, { start: start_date, end: end_date })
  }

  # Users should not be able to make ex post facto bookings, unless they
  # are an admin.
  def cannot_be_in_the_past
    if self.start_time.present? && self.start_time < Time.zone.now
      errors.add(:start_time, "can't be in the past.") unless self.user.nil? || self.user.admin?
    end
  end

  # Prevent a show making bookings that occur after the show's final performance.
  # Also prevent any bookings that occur more than four months in advance.
  def cannot_be_too_far_in_future
    if self.start_time.present?
      if self.camdram_model.present? && self.camdram_model.instance_of?(CamdramShow)
        performances = self.camdram_model.camdram_object.performances
        last_performance = performances.sort { |p1, p2| p1.end_at - p2.end_at }.last
        if self.start_time > last_performance.end_at
          errors.add(:start_time, "is too far in the future.") unless self.user.admin?
        end
      elsif self.start_time > Time.zone.now + 4.months
        errors.add(:start_time, "is too far in the future.") unless self.user.admin?
      end
    end
  end

  # Scheduled bookings can only be made between 08:00 and 23:59.
  def cannot_be_during_quiet_hours
    if self.start_time.present? && self.start_time.hour < 8
      errors.add(:start_time, "can't be between midnight and 8am.")
    end
    if self.end_time.present? && self.end_time.hour < 8 && self.end_time != self.end_time.midnight
      errors.add(:end_time, "can't be between midnight and 8am.")
    end
  end

  def must_end_on_same_day
    if self.start_time.present? && self.end_time.present? && self.end_time.to_date != self.start_time.to_date
      unless self.end_time == self.start_time.midnight + 1.day
        errors.add(:end_time, "is on a different day to the booking start time.")
      end
    end
  end

  # Bookings should fit into 30 minute time slots.
  def must_fill_half_hour_slot
    if self.start_time.present? && self.start_time.min % 30 != 0
      errors.add(:start_time, 'must be a multiple of thirty minutes.')
    end
    if self.duration.present? && self.duration % 1800 != 0
      errors.add(:duration, 'must be a multiple of thirty minutes.')
    end
  end

  # A booking cannot overlap with any other booking.
  def must_not_overlap
    # Needs to have start & end time and a venue to validate overlap.
    return if (self.start_time.nil? || self.end_time.nil? || self.room.nil?)
    st = self.start_time
    et = case self.repeat_mode
    when 'none' then self.end_time
    else self.repeat_until || return
    end
    overlapping_bookings = self.room.bookings.where.not(id: self.id)
      .in_range(st.to_date, et.to_date + 1.day)
      .select { |b| b.overlaps?(self) }
    unless overlapping_bookings.empty?
      url = Roombooking::UrlGenerator.url_for(overlapping_bookings.first)
      errors.add(:base, "The times given overlap with another booking [here](#{url}).")
    end
  end

  def repeat_until_must_be_valid
    if self.repeat_mode != 'none'
      if repeat_until.blank?
        errors.add(:repeat_until, 'must be set')
      elsif self.start_time.present? && repeat_until < self.start_time.to_date
        errors.add(:repeat_until, "must be after the booking's start time.")
      end
    else
      self.repeat_until = nil
    end
  end

  # Ensures that the excluded date string contains parsable Ruby dates.
  def excluded_repeat_dates_must_be_valid
    if self.repeat_mode == 'none'
      self.excluded_repeat_dates = nil
      return
    end
    return if self.excluded_repeat_dates.blank?
    return if self.repeat_until.nil?
    start = self.start_time.to_date
    finish = self.repeat_until
    arr = Array.new
    (start..finish).each do |date|
      if self.repeat_mode == 'daily' ||
        (self.repeat_mode == 'weekly' && date.wday == start.wday)
        arr << date
      end
    end
    str = self.excluded_repeat_dates.split(',').select { |date_string|
      begin
        arr.include? date_string.to_date
      rescue
        errors.add(:excluded_repeat_dates, "is invalid - \"#{date_string}\" cannot be converted to a date.")
      end
    }.join(',')
    self.excluded_repeat_dates = str
  end

  # A booking must have an associated Camdram model if required by its purpose.
  def camdram_model_must_be_valid
    return if self.purpose.nil?
    if Booking.purposes_with_none.include?(self.purpose.to_sym)
      self.camdram_model = nil
    else
      if self.camdram_model.nil?
        errors.add(:purpose, 'needs to be a valid selection.')
      elsif self.camdram_model.camdram_object.nil?
        errors.add(:base, 'Your show or society appears to have been deleted from Camdram. Please contact support.')
      end
    end
  end

  # A booking with an associated Camdram model must not go over it's weekly quota.
  def must_not_exceed_quota
    return if self.purpose.nil? || self.camdram_model.nil? || self.duration.nil?
    unless Booking.purposes_with_none.include?(self.purpose.to_sym)
      start = self.start_time.to_date.beginning_of_week
      weeks_to_check = []
      if self.repeat_mode == 'none'
        weeks_to_check.append start
      elsif self.repeat_until.blank?
        return
      else
        while start <= repeat_until do
          weeks_to_check.append start
          start += 1.week
        end
      end
      weeks_to_check.each do |start_of_week|
        end_of_week = start_of_week + 1.week
        bookings = self.camdram_model.bookings
          .where.not(id: self.id)
          .in_range(start_of_week, end_of_week)
        bookings << self
        quota = self.camdram_model.calculate_weekly_quota(start_of_week, bookings)
        if self.camdram_model.exceeded_weekly_quota?(quota)
          errors.add(:base, "You have exceeded your weekly booking quota (for the week beginning #{start_of_week.to_date}).")
        end
      end
    end
  end

  # The booking's selected room must allow a show's camdram venue.
  def room_must_allow_camdram_venue
    if self.room.present? && self.camdram_model.instance_of?(CamdramShow)
      return if self.camdram_model.camdram_object.nil?
      permitted_ids = self.room.camdram_venues.map(&:camdram_id)
      self.camdram_model.camdram_object.performances.each do |performance|
        next if performance.venue.nil?
        return if permitted_ids.include?(performance.venue.id)
      end
      errors.add(:base, "Your show may not make bookings for this room.")
    end
  end

  # Ensure the booking as a descriptive title, as much as is possible.
  def name_must_be_descriptive
    if self.name.present?
      test_name = I18n.transliterate(self.name.downcase).gsub(/[^a-z]/, '')
      if self.user.present?
        test_user_name = I18n.transliterate(self.user.name.downcase).gsub(/[^a-z]/, '')
        errors.add(:name, "needs to be more descriptive.") if test_name == test_user_name
      end
      if self.camdram_model.present?
        test_camdram_name = I18n.transliterate(self.camdram_model.name.downcase).gsub(/[^a-z]/, '')
        errors.add(:name, "needs to be more descriptive.") if test_name == test_camdram_name
      end
    end
  end

  def attendees_must_conform
    errors.add(:attendees, "must list those who will be attending the booking.") if self.attendees.empty?
    errors.add(:attendees, "list more than six people, which is the maximum.") if self.attendees.length > 6
  end

  def user_must_be_allowed_to_book_room
    return unless self.room && self.user
    if self.room.admin_only? && !self.user.admin?
      errors.add(:base, "Only management may make booking for this room.")
    end
  end

  def attendees_text
    self.attendees.map(&:to_s).join("\r\n")
  end

  def attendees_text=(string)
    atds = []
    lines = string.chomp.split("\r\n")
    lines.each do |line|
      attendee = Attendee.parse(line)
      atds << attendee if attendee.try(:valid?)
    end
    self.attendees = atds
  end

  # Prettified string describing the booking's duration.
  def length
    @length ||= self.duration ? ChronicDuration.output(self.duration, :format => :long) : nil
  end

  # Sets the booking's end_time database field by parsing the given string
  # using ChronicDuration.
  def length=(string)
    @length = string
    len = nil
    if string =~ /\A(\d+)\z/
      len = string.to_i
    elsif parsed_time = ChronicDuration.parse(string)
      len = parsed_time
    end
    self.end_time = self.start_time + len if (self.start_time && len)
  end

  # Returns the duration of the booking.
  def duration
    @duration ||= self.end_time && self.start_time ? self.end_time - self.start_time : nil
  end

  # Returns an array of dates that are excluded from the booking repeat cycle.
  def excluded_dates_array
    return [] unless self.excluded_repeat_dates.present?
    self.excluded_repeat_dates.split(',').map(&:to_date)
  end

  # Returns a human-friendly string describing the booking's purpose.
  def purpose_string
    string = self.purpose.humanize
    string += %Q[ "#{self.camdram_model.name}"] unless self.camdram_model.nil?
    string
  end

  # Returns the Camdram object that the booking references.
  def camdram_object
    # We try and call the method because not all bookings have
    # Camdram models associated with them. This returns either
    # the Camdram object or nil.
    self.camdram_model.try(:camdram_object)
  end

  # Iterates over each day that the booking occupies.
  def repeat_iterator
    excludes = excluded_dates_array
    if self.repeat_mode == 'none'
      yield(self.start_time, self.end_time)
    elsif self.repeat_mode == 'daily'
      end_point = self.repeat_until + 1.day
      st = self.start_time
      et = self.end_time
      begin
        yield(st, et) unless excludes.include?(st.to_date)
        st += 1.day
        et += 1.day
      end until st > end_point
    elsif self.repeat_mode == 'weekly'
      end_point = self.repeat_until + 1.day
      st = self.start_time
      et = self.end_time
      begin
        yield(st, et) unless excludes.include?(st.to_date)
        st += 1.week
        et += 1.week
      end until st > end_point
    end
  end

  # True if the booking overlaps at all with the other booking that's
  # passed as a parameter, false otherwise.
  def overlaps?(booking)
    return false if self.room != booking.room
    self.repeat_iterator do |st1, et1|
      booking.repeat_iterator do |st2, et2|
        if st2 < st1
          return true if et2 > st1
        else
          return true if st2 < et1
        end
      end
    end
    false
  end
end
