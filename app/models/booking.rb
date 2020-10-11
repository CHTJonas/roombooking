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
  strip_attributes only: %i[name notes excluded_repeat_dates]
  paginates_per 9
  include PgSearch::Model
  pg_search_scope :search_by_name_and_notes, against: { name: 'A', notes: 'B' },
                                             ignoring: :accents, using: { tsearch: { prefix: true, dictionary: 'english' },
                                                                          dmetaphone: { any_word: true }, trigram: { only: [:name] } }

  def self.admin_purposes
    %i[performance_of get_in_for theatre_closed training other audition_for meeting_for meeting_of]
  end

  def self.purposes_with_shows
    %i[audition_for meeting_for performance_of rehearsal_for get_in_for]
  end

  def self.purposes_with_societies
    [:meeting_of]
  end

  def self.purposes_with_none
    %i[theatre_closed training other]
  end

  enum repeat_mode: %i[none daily weekly], _prefix: :repeat_mode
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
  validate :cannot_be_outside_management_hours

  # Scope all bookings that occur between the two given dates. Note that
  # end_date should be midnight of the day after the last day you'd like
  # to include in the query.
  scope :in_range, lambda { |start_date, end_date|
    ordinary_in_range(start_date, end_date) +
      daily_repeat_in_range(start_date, end_date) +
      weekly_repeat_in_range(start_date, end_date)
  }

  # Scope non-repeating bookings that occur between the two given dates.
  # Note that end_date should be midnight of the day after the last day
  # you'd like to include in the query.
  scope :ordinary_in_range, lambda { |start_date, end_date|
    where(repeat_mode: :none)
      .where(start_time: start_date..end_date)
  }

  # Scope bookings that repeat daily and which occur between the two given
  # dates. Note that end_date should be midnight of the day after the last
  # day you'd like to include in the query.
  scope :daily_repeat_in_range, lambda { |start_date, end_date|
    where(repeat_mode: :daily)
      .where(start_time: Time.at(0)..end_date)
      .where(repeat_until: start_date..DateTime::Infinity.new)
  }

  # Scope bookings that repeat weekly and which occur between the two given
  # dates. Note that end_date should be midnight of the day after the last
  # day you'd like to include in the query.
  scope :weekly_repeat_in_range, lambda { |start_date, end_date|
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
    if start_time.present? && start_time < Time.zone.now
      errors.add(:start_time, "can't be in the past.") unless user.nil? || user.admin?
    end
  end

  # Prevent a show making bookings that occur after the show's final performance.
  # Also prevent any bookings that occur more than four months in advance.
  def cannot_be_too_far_in_future
    if start_time.present?
      if camdram_model.present? && camdram_model.instance_of?(CamdramShow)
        performances = camdram_model.camdram_object.performances
        last_performance = performances.max { |p1, p2| p1.end_at - p2.end_at }
        if start_time > last_performance.end_at
          errors.add(:start_time, 'is too far in the future.') unless user.admin?
        end
      elsif start_time > Time.zone.now + 4.months
        errors.add(:start_time, 'is too far in the future.') unless user.admin?
      end
    end
  end

  # Scheduled bookings can only be made between 08:00 and 23:59.
  def cannot_be_during_quiet_hours
    errors.add(:start_time, "can't be between midnight and 8am.") if start_time.present? && start_time.hour < 8
    if end_time.present? && end_time.hour < 8 && end_time != end_time.midnight
      errors.add(:end_time, "can't be between midnight and 8am.")
    end
  end

  def must_end_on_same_day
    if start_time.present? && end_time.present? && end_time.to_date != start_time.to_date
      unless end_time == start_time.midnight + 1.day
        errors.add(:end_time, 'is on a different day to the booking start time.')
      end
    end
  end

  # Bookings should fit into 30 minute time slots.
  def must_fill_half_hour_slot
    errors.add(:start_time, 'must be a multiple of thirty minutes.') if start_time.present? && start_time.min % 30 != 0
    errors.add(:duration, 'must be a multiple of thirty minutes.') if duration.present? && duration % 1800 != 0
  end

  # A booking cannot overlap with any other booking.
  def must_not_overlap
    # Needs to have start & end time and a venue to validate overlap.
    return if start_time.nil? || end_time.nil? || room.nil?

    st = start_time
    et = case repeat_mode
         when 'none' then end_time
         else repeat_until || return
         end
    overlapping_bookings = room.bookings.where.not(id: id)
                               .in_range(st.to_date, et.to_date + 1.day)
                               .select { |b| b.overlaps?(self) }
    unless overlapping_bookings.empty?
      url = Roombooking::UrlGenerator.url_for(overlapping_bookings.first)
      errors.add(:base, "The times given overlap with another booking [here](#{url}).")
    end
  end

  def repeat_until_must_be_valid
    if repeat_mode != 'none'
      if repeat_until.blank?
        errors.add(:repeat_until, 'must be set')
      elsif start_time.present? && repeat_until < start_time.to_date
        errors.add(:repeat_until, "must be after the booking's start time.")
      end
    else
      self.repeat_until = nil
    end
  end

  # Ensures that the excluded date string contains parsable Ruby dates.
  def excluded_repeat_dates_must_be_valid
    if repeat_mode == 'none'
      self.excluded_repeat_dates = nil
      return
    end
    return if excluded_repeat_dates.blank?
    return if repeat_until.nil?

    start = start_time.to_date
    finish = repeat_until
    arr = []
    (start..finish).each do |date|
      if repeat_mode == 'daily' ||
         (repeat_mode == 'weekly' && date.wday == start.wday)
        arr << date
      end
    end
    str = excluded_repeat_dates.split(',').select do |date_string|
      arr.include? date_string.to_date
          rescue StandardError
            errors.add(:excluded_repeat_dates, "is invalid - \"#{date_string}\" cannot be converted to a date.")
    end.join(',')
    self.excluded_repeat_dates = str
  end

  # A booking must have an associated Camdram model if required by its purpose.
  def camdram_model_must_be_valid
    return if purpose.nil?

    if Booking.purposes_with_none.include?(purpose.to_sym)
      self.camdram_model = nil
    else
      if camdram_model.nil?
        errors.add(:purpose, 'needs to be a valid selection.')
      elsif camdram_model.camdram_object.nil?
        errors.add(:base, 'Your show or society appears to have been deleted from Camdram. Please contact support.')
      end
    end
  end

  # A booking with an associated Camdram model must not go over it's weekly quota.
  def must_not_exceed_quota
    return if purpose.nil? || camdram_model.nil? || duration.nil?

    unless Booking.purposes_with_none.include?(purpose.to_sym)
      start = start_time.to_date.beginning_of_week
      weeks_to_check = []
      if repeat_mode == 'none'
        weeks_to_check.append start
      elsif repeat_until.blank?
        return
      else
        while start <= repeat_until
          weeks_to_check.append start
          start += 1.week
        end
      end
      weeks_to_check.each do |start_of_week|
        end_of_week = start_of_week + 1.week
        bookings = camdram_model.bookings
                                .where.not(id: id)
                                .in_range(start_of_week, end_of_week)
        bookings << self
        quota = camdram_model.calculate_weekly_quota(start_of_week, bookings)
        if camdram_model.exceeded_weekly_quota?(quota)
          errors.add(:base, "You have exceeded your weekly booking quota (for the week beginning #{start_of_week.to_date}).")
        end
      end
    end
  end

  # The booking's selected room must allow a show's camdram venue.
  def room_must_allow_camdram_venue
    if room.present? && camdram_model.instance_of?(CamdramShow)
      return if camdram_model.camdram_object.nil?

      permitted_ids = room.camdram_venues.map(&:camdram_id)
      camdram_model.camdram_object.performances.each do |performance|
        next if performance.venue.nil?
        return if permitted_ids.include?(performance.venue.id)
      end
      errors.add(:base, 'Your show may not make bookings for this room.')
    end
  end

  # Ensure the booking as a descriptive title, as much as is possible.
  def name_must_be_descriptive
    if name.present?
      test_name = I18n.transliterate(name.downcase).gsub(/[^a-z]/, '')
      if user.present?
        test_user_name = I18n.transliterate(user.name.downcase).gsub(/[^a-z]/, '')
        errors.add(:name, 'needs to be more descriptive.') if test_name == test_user_name
      end
      if camdram_model.present?
        test_camdram_name = I18n.transliterate(camdram_model.name.downcase).gsub(/[^a-z]/, '')
        errors.add(:name, 'needs to be more descriptive.') if test_name == test_camdram_name
      end
    end
  end

  def attendees_must_conform
    unless purpose.nil? || Booking.admin_purposes.include?(purpose.to_sym)
      errors.add(:attendees, 'must list those who will be attending the booking.') if attendees.empty?
      errors.add(:attendees, 'list more than six people, which is the maximum.') if attendees.length > 6
    end
  end

  def user_must_be_allowed_to_book_room
    return unless room && user

    errors.add(:base, 'Only management may make booking for this room.') if room.admin_only? && !user.admin?
  end

  def cannot_be_outside_management_hours
    return if user.try(:admin?)

    if start_time.present? && (start_time.hour < 11 || start_time.hour >= 18)
      errors.add(:start_time, "can't be outside management hours.")
    end
    if end_time.present? && (end_time.hour <= 11 || end_time.hour > 18)
      errors.add(:end_time, "can't be outside management hours.")
    end
  end

  def attendees_text
    attendees.map(&:to_s).join("\r\n")
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
    @length ||= duration ? ChronicDuration.output(duration, format: :long) : nil
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
    self.end_time = start_time + len if start_time && len
  end

  # Returns the duration of the booking.
  def duration
    @duration ||= end_time && start_time ? end_time - start_time : nil
  end

  # Returns an array of dates that are excluded from the booking repeat cycle.
  def excluded_dates_array
    return [] unless excluded_repeat_dates.present?

    excluded_repeat_dates.split(',').map(&:to_date)
  end

  # Returns a human-friendly string describing the booking's purpose.
  def purpose_string
    string = purpose.humanize
    string += %( "#{camdram_model.name}") unless camdram_model.nil?
    string
  end

  # Returns the Camdram object that the booking references.
  def camdram_object
    # We try and call the method because not all bookings have
    # Camdram models associated with them. This returns either
    # the Camdram object or nil.
    camdram_model.try(:camdram_object)
  end

  # Iterates over each day that the booking occupies.
  def repeat_iterator
    excludes = excluded_dates_array
    if repeat_mode == 'none'
      yield(start_time, end_time)
    elsif repeat_mode == 'daily'
      end_point = repeat_until + 1.day
      st = start_time
      et = end_time
      loop do
        yield(st, et) unless excludes.include?(st.to_date)
        st += 1.day
        et += 1.day
        break if st > end_point
      end
    elsif repeat_mode == 'weekly'
      end_point = repeat_until + 1.day
      st = start_time
      et = end_time
      loop do
        yield(st, et) unless excludes.include?(st.to_date)
        st += 1.week
        et += 1.week
        break if st > end_point
      end
    end
  end

  # True if the booking overlaps at all with the other booking that's
  # passed as a parameter, false otherwise.
  def overlaps?(booking)
    return false if room != booking.room

    repeat_iterator do |st1, et1|
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
