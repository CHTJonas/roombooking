# == Schema Information
#
# Table name: bookings
#
#  id                 :bigint(8)        not null, primary key
#  name               :string           not null
#  notes              :text
#  start_time         :datetime         not null
#  end_time           :datetime         not null
#  repeat_until       :date
#  repeat_mode        :integer          default("none"), not null
#  purpose            :integer          not null
#  approved           :boolean          default(FALSE), not null
#  room_id            :bigint(8)        not null
#  user_id            :bigint(8)        not null
#  camdram_model_type :string
#  camdram_model_id   :bigint(8)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Booking < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name_and_notes,
                   against: {
                     name: 'A',
                     notes: 'B'
                   },
                   ignoring: :accents,
                   using: {
                     tsearch: {
                       prefix: true,
                       dictionary: 'english'
                     },
                     dmetaphone: {
                       any_word: true
                     },
                     trigram: {
                       only: [:name]
                     },
                   }

  paginates_per 9

  enum repeat_mode: [ :none, :daily, :weekly ], _prefix: :repeat_mode

  enum purpose: [ :audition_for, :meeting_for, :meeting_of, :performance_of, :rehearsal_for, :get_in_for, :theatre_closed, :training, :other ], _prefix: :purpose
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

  belongs_to :room
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

  # Bookings should fit to 30 minute time slots.
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
    query_opts = { start: self.start_time, end: self.end_time }
    query_end_time = case self.repeat_mode
    when 'none' then self.end_time
    else self.repeat_until
    end

    ordinary_bookings = Booking.where.not(id: self.id)
      .where(repeat_mode: :none)
      .where(room: self.room)
      .where(%{start_time BETWEEN :start AND :end OR end_time BETWEEN :start AND :end}, query_opts)

    daily_repeat_bookings = Booking.where.not(id: self.id)
      .daily_repeat_in_range(self.start_time, query_end_time)
      .where(room: self.room)
      .where(%{ (start_time::time, end_time::time)
OVERLAPS (timestamp :start::time, timestamp :end::time) }, query_opts)

    weekly_repeat_bookings = Booking.where.not(id: self.id)
      .weekly_repeat_in_range(self.start_time, query_end_time)
      .where(room: self.room)
      .where(%{ (start_time::time, end_time::time)
OVERLAPS (timestamp :start::time, timestamp :end::time)
AND EXTRACT(dow FROM start_time) = EXTRACT(dow FROM timestamp :start) }, query_opts)

    unless ordinary_bookings.empty? && daily_repeat_bookings.empty? && weekly_repeat_bookings.empty?
      errors.add(:base, 'The times given overlap with another booking.')
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
    unless self.purpose.nil? || Booking.purposes_with_none.find_index(self.purpose.to_sym)
      errors.add(:purpose, 'needs to be a valid selection.') if camdram_model.nil?
    end
  end

  # A booking with an associated Camdram model must not go over it's weekly quota.
  def must_not_exceed_quota
    unless self.purpose.nil? || Booking.purposes_with_none.find_index(self.purpose.to_sym)
      start = self.start_time.to_date.beginning_of_week
      weeks_to_check = []
      if self.repeat_mode == 'none'
        weeks_to_check.append start
      else
        while start <= repeat_until do
          weeks_to_check.append start
          start += 1.week
        end
      end
      weeks_to_check.each do |start_of_week|
        end_of_week = start_of_week + 1.week
        bookings = self.camdram_model.booking
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

  # Prettified string describing the booking's duration.
  def length
    @length ||= self.duration ? ChronicDuration.output(self.duration, :format => :long) : nil
  end

  # Sets the booking's end_time database field by parsing the given string
  # using ChronicDuration.
  def length=(string)
    @length = string
    if string =~ /\A(\d+)\z/
      @length = string.to_i
    elsif parsed_time = ChronicDuration.parse(string)
      @length = parsed_time
    else
      @length = nil
    end
    self.end_time = self.start_time + @length if self.start_time && @length
  end

  # Returns the duration of the booking.
  def duration
    @duration ||= self.end_time && self.start_time ? self.end_time - self.start_time : nil
  end

  def purpose_string
    string = self.purpose.humanize
    string << %Q[ "#{camdram_object.name}"] unless camdram_object.nil?
    return string
  end

  # Returns the Camdram object the booking references.
  def camdram_object
    # We try and call the method because not all bookings have associated Camdram models
    self.camdram_model.try(:camdram_object)
  end

  # Scope approved bookings only.
  scope :approved, -> { where(approved: true) }

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

  def to_event(offset = 0)
    Event.create_from_booking(self, offset)
  end
end
