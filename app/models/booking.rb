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

  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :duration, numericality: {
    greater_than_or_equal_to: 1800,
    message: 'must be at least 30 minutes'
  }
  validates :purpose, presence: true

  validate :cannot_be_in_the_past
  validate :cannot_be_during_quiet_hours
  validate :must_fill_half_hour_slot
  validate :must_not_overlap
  validate :repeat_until_must_be_valid
  validate :camdram_model_must_be_valid
  validate :must_not_exceed_quota
  validate :room_must_allow_camdram_venue

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
    .where(%{
EXTRACT(dow FROM timestamp :start) <= EXTRACT(dow FROM start_time)
AND EXTRACT(dow FROM start_time) < EXTRACT(dow FROM timestamp :start) +
DATE_PART('day', timestamp :end - timestamp :start) },
      { start: start_date, end: end_date })
  }

  # Users should not be able to make ex post facto bookings, unless they
  # are an admin.
  def cannot_be_in_the_past
    if self.start_time.present? && self.start_time < DateTime.now
      errors.add(:start_time, "can't be in the past.") unless self.user.admin?
    end
  end

  # Scheduled bookings can only be made between 08:00 and 23:59.
  def cannot_be_during_quiet_hours
    if self.start_time.present? && self.start_time.hour < 8
      errors.add(:start_time, "can't be between midnight and 8am.")
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
    # Needs to have start and end time to validate overlap.
    return if (self.start_time.nil? || self.end_time.nil?)
    st = self.start_time
    et = case self.repeat_mode
    when 'none' then self.end_time
    else self.repeat_until || return
    end
    overlapping_bookings = Booking.where.not(id: self.id)
      .in_range(st, et)
      .select { |b| b.overlaps?(self) }
    unless overlapping_bookings.empty?
      url = Roombooking::UrlGenerator.url_for(overlapping_bookings.first)
      errors.add(:base, "The times given overlap with another booking [here](#{url}).")
    end
  end

  def repeat_until_must_be_valid
    if self.repeat_mode != 'none'
      if repeat_until.nil?
        errors.add(:repeat_until, 'must be set')
      elsif repeat_until < self.start_time.to_date
        errors.add(:repeat_until, "must be after the booking's start time.")
      end
    end
  end

  # A booking must have an associated Camdram model if required by its purpose.
  def camdram_model_must_be_valid
    return if self.purpose.nil?
    if Booking.purposes_with_none.find_index(self.purpose.to_sym)
      self.camdram_model = nil
    else
      errors.add(:purpose, 'needs to be a valid selection.') if self.camdram_model.nil?
      errors.add(:base, 'Your show or society appears to have been deleted from Camdram. Please contact support.') if self.camdram_model.camdram_object.nil?
    end
  end

  # A booking with an associated Camdram model must not go over it's weekly quota.
  def must_not_exceed_quota
    unless self.purpose.nil? || Booking.purposes_with_none.find_index(self.purpose.to_sym) || self.camdram_model.nil?
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
      unless self.room.camdram_venues.map(&:camdram_id).include?(self.camdram_model.camdram_object.venue.id)
        errors.add(:base, "Your show may not make bookings for this room.")
      end
    end
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

  # Sets the dates that are excluded from the booking repeat cycle.
  def excluded_repeat_dates=(string)
    return super(nil) if self.repeat_mode == 'none'
    start = self.start_time.to_date
    finish = self.repeat_until
    arr = Array.new
    (start..finish).each do |date|
      if self.repeat_mode == 'daily' ||
        (self.repeat_mode == 'weekly' && date.wday == start.wday)
        arr << date
      end
    end
    super string.split(',').select { |s|
      arr.include? s.to_date
    }.join
  end

  # Returns an array of dates that are excluded from the booking repeat cycle.
  def excluded_dates_array
    return [] unless self.excluded_repeat_dates.present?
    self.excluded_repeat_dates.split(',').map(&:to_date)
  end

  # Returns a human-friendly string describing the booking's purpose.
  def purpose_string
    string = self.purpose.humanize
    string += %Q[ "#{camdram_object.name}"] unless camdram_object.nil?
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
