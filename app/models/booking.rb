class Booking < ApplicationRecord
  enum purpose: [ :audition_for, :meeting_for, :meeting_of, :performance_of, :rehearsal_for, :get_in_for, :theatre_closed, :training, :other ]
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
  belongs_to :camdram_object, optional: true
  validates_associated :venue
  validates_associated :user

  validates :name, presence: true
  validates :when, presence: true
  validates :purpose, presence: true
  validates :duration, :numericality => {:greater_than_or_equal_to => 1800, :message => "must be at least 30 minutes"}

  validate :cannot_be_in_the_past
  validate :cannot_be_during_quiet_hours
  validate :must_fill_half_hour_slot
  validate :camdram_id_must_be_valid

  def cannot_be_in_the_past
    if self.when.present? && self.when < Date.today
      errors.add(:when, "can't be in the past") unless self.user.admin?
    end
  end

  def cannot_be_during_quiet_hours
    if self.when.present? && self.when.hour < 8
      errors.add(:when, "can't be between midnight and 8am")
    end
  end

  def must_fill_half_hour_slot
    if self.when.present? && self.when.min % 30 != 0
      errors.add(:when, "must be a multiple of thirty minutes")
    end
    if self.duration.present? && self.duration % 1800 != 0
      errors.add(:duration, "must be a multiple of thirty minutes")
    end
  end

  def camdram_id_must_be_valid
    return if self.purpose.nil? # if no purpose has been selected just return
    unless Booking.purposes_with_none.find_index(self.purpose.to_sym)
      errors.add(:purpose, "needs to be a valid selection") if camdram_id.nil?
    end
  end

  def length
    @length ||= self.duration ? ChronicDuration.output(self.duration, :format => :long) : nil
  end

  def length=(string)
    @length = string
    if string =~ /\A(\d+)\z/
      self.duration = string.to_i
    elsif parsed_time = ChronicDuration.parse(string)
      self.duration = parsed_time
    else
      self.duration = nil
    end
  end

  def purpose_string
    string = self.purpose.humanize
    string << %Q[ "#{camdram_object.name}"] if !self.camdram_id.nil?
    return string
  end

  def finish_time
    # Gets the finish time based on the start time and the duration
    if self.when && self.duration
      self.when + self.duration
    end
  end

  # Helper method for calendar
  def start_time
    self.when
  end

  # Helper method for calendar
  def end_time
    self.finish_time
  end

  # Returns the Camdram object the booking references
  def camdram_object
    if Booking.purposes_with_shows.find_index(self.purpose.to_sym)
      return camdram.get_show(self.camdram_id)
    elsif Booking.purposes_with_societies.find_index(self.purpose.to_sym)
      return camdram.get_org(self.camdram_id)
    else
      return nil
    end
  end

  private

  def camdram
    @camdram ||= Camdram::Client.new do |config|
      config.api_token = nil
      config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
    end
  end
end
