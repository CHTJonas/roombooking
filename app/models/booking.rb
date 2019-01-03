class Booking < ApplicationRecord
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

  belongs_to :venue
  belongs_to :user
  belongs_to :camdram_model, polymorphic: true, required: false
  validates_associated :venue
  validates_associated :user
  validates_associated :camdram_model

  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :duration, numericality: {
    greater_than_or_equal_to: 1800, message: 'must be at least 30 minutes'
  }
  validates :purpose, presence: true

  validate :cannot_be_in_the_past
  validate :cannot_be_during_quiet_hours
  validate :must_fill_half_hour_slot
  validate :must_not_overlap
  validate :camdram_model_must_be_valid

  # Users should not be able to make ex post facto bookings, unless they
  # are an admin.
  def cannot_be_in_the_past
    if self.start_time.present? && self.start_time < DateTime.now
      errors.add(:start_time, "can't be in the past") unless self.user.admin?
    end
  end

  # Scheduled bookings can only be made between 08:00 and 23:59.
  def cannot_be_during_quiet_hours
    if self.start_time.present? && self.start_time.hour < 8
      errors.add(:start_time, "can't be between midnight and 8am")
    end
  end

  # Bookings should fit to 30 minute time slots.
  def must_fill_half_hour_slot
    if self.start_time.present? && self.start_time.min % 30 != 0
      errors.add(:start_time, "must be a multiple of thirty minutes")
    end
    if self.duration.present? && self.duration % 1800 != 0
      errors.add(:duration, "must be a multiple of thirty minutes")
    end
  end

  # Two bookings cannot be made inthe same place at the same time.
  def must_not_overlap
    unless Booking.where("id != :id AND (start_time BETWEEN :start AND :end OR end_time BETWEEN :start AND :end)", {id: self.id, start: self.start_time, end: self.end_time}).empty?
      errors.add(:base, "The times given overlap with another booking")
    end
  end

  # A booking must have an associated Camdram model if required by its purpose.
  def camdram_model_must_be_valid
    unless self.purpose.nil? || Booking.purposes_with_none.find_index(self.purpose.to_sym)
      errors.add(:purpose, "needs to be a valid selection") if camdram_model.nil?
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
end
