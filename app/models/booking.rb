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
  validates_associated :room
  validates_associated :user
  validates_associated :camdram_model

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
      errors.add(:start_time, "must be a multiple of thirty minutes.")
    end
    if self.duration.present? && self.duration % 1800 != 0
      errors.add(:duration, "must be a multiple of thirty minutes.")
    end
  end

  # Two bookings cannot be made inthe same place at the same time.
  def must_not_overlap
    unless Booking.where("id != :id AND (start_time BETWEEN :start AND :end OR end_time BETWEEN :start AND :end)", {id: self.id, start: self.start_time, end: self.end_time}).empty?
      errors.add(:base, "The times given overlap with another booking.")
    end
  end

  def repeat_until_must_be_valid
    if self.repeat_mode != 'none'
      if repeat_until.nil?
        errors.add(:repeat_until, "must be set")
      elsif repeat_until < self.start_time.to_date
        errors.add(:repeat_until, "must be after the booking's start time.")
      end
    end
  end

  # A booking must have an associated Camdram model if required by its purpose.
  def camdram_model_must_be_valid
    unless self.purpose.nil? || Booking.purposes_with_none.find_index(self.purpose.to_sym)
      errors.add(:purpose, "needs to be a valid selection.") if camdram_model.nil?
    end
  end

  # A booking with an associated Camdram model must not go over it's weekly quota.
  def must_not_exceed_quota
    unless self.purpose.nil? || Booking.purposes_with_none.find_index(self.purpose.to_sym)
      start = self.start_time.beginning_of_week
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
        error_message = validate_weekly_quota(start_of_week)
        if error_message
          errors.add(:base, error_message)
          return
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

  # Returns the CSS colour of the booking as determined by the booking's type.
  def css_colour
    case self.purpose.to_sym
    when :audition_for
      "\#FFFF00"
    when :meeting_for
      "\#00FFAA"
    when :meeting_of
      "\#00DDFF"
    when :performance_of
      "\#FF00FF"
    when :rehearsal_for
      "\#00FF00"
    when :get_in_for
      "\#FFAAAA"
    when :theatre_closed
      "\#FF0000"
    when :training
      "\#BFBFBF"
    else
      "\#888888"
    end
  end

  private

  def validate_weekly_quota(start_of_week)
    end_of_week = start_of_week + 1.week

    # We exclude the current record from our queries throughout because we
    # may be updating the model and so want to validate the current state,
    # not the state which may be stored in the database. This is achieved
    # using the calls to `append self` on the arrays of ActiveRecords.

    ordinary_bookings = Booking.where.not(id: self.id)
                      .where(repeat_mode: :none)
                      .where(start_time: start_of_week..end_of_week)
                      .where(room: self.room)
                      .where(camdram_model: self.camdram_model)
                      .where(purpose: self.purpose)
                      .to_a
    ordinary_bookings.append self if self.repeat_mode == 'none'
    total_hours = 0
    ordinary_bookings.each do |booking|
      duration = booking.duration
      # Convert duration from seconds to hours.
      total_hours += duration / 60 / 60
    end

    daily_repeat_bookings = Booking.where.not(id: self.id)
                                   .where(repeat_mode: :daily)
                                   .where(start_time: Time.at(0)..end_of_week)
                                   .where(repeat_until: start_of_week..DateTime::Infinity.new)
                                   .where(room: self.room)
                                   .where(camdram_model: self.camdram_model)
                                   .where(purpose: self.purpose)
                                   .to_a
    daily_repeat_bookings.append self if self.repeat_mode == 'daily'
    daily_repeat_bookings.each do |booking|
      duration = booking.duration
      # Convert duration from seconds to hours.
      hours = duration / 60 / 60
      repeat_start_time = [booking.start_time, start_of_week].max
      repeat_end_time = [booking.repeat_until + 1.day, end_of_week].min
      (repeat_start_time.to_date...repeat_end_time.to_date).each do |date|
        total_hours += hours
      end
    end

    weekly_repeat_bookings = Booking.where.not(id: self.id)
                                   .where(repeat_mode: :weekly)
                                   .where(start_time: Time.at(0)..end_of_week)
                                   .where(repeat_until: start_of_week..DateTime::Infinity.new)
                                   .where(room: self.room)
                                   .where(camdram_model: self.camdram_model)
                                   .where(purpose: self.purpose)
                                   .to_a
    weekly_repeat_bookings.append self if self.repeat_mode == 'weekly'
    weekly_repeat_bookings.each do |booking|
      duration = booking.duration
      # Convert duration from seconds to hours.
      hours = duration / 60 / 60
      total_hours += hours
    end

    if self.purpose == 'audition_for' && total_hours > self.camdram_model.max_auditions
      return "Your show has exceeded its weekly audition booking quota for the week beginning #{start_of_week.to_date} by #{total_hours - self.camdram_model.max_auditions} hours."
    elsif self.purpose == 'meeting_for' && total_hours > self.camdram_model.max_meetings
      return "Your show has exceeded its weekly meeting booking quota for the week beginning #{start_of_week.to_date} by #{total_hours - self.camdram_model.max_meetings} hours."
    elsif self.purpose == 'meeting_of' && total_hours > self.camdram_model.max_meetings
      return "Your society has exceeded its weekly meeting booking quota for the week beginning #{start_of_week.to_date} by #{total_hours - self.camdram_model.max_meetings} hours."
    elsif self.purpose == 'rehearsal_for' && total_hours > self.camdram_model.max_rehearsals
      return "Your show has exceeded its weekly rehearsal booking quota for the week beginning #{start_of_week.to_date} by #{total_hours - self.camdram_model.max_rehearsals} hours."
    end

    # This week validated correctly so return nil.
    nil
  end
end
