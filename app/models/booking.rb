class Booking < ApplicationRecord
  belongs_to :venue
  belongs_to :user
  validates_associated :venue
  validates_associated :user

  validates :name, presence: true
  validates :when, presence: true
  validates :duration, :numericality => {:greater_than_or_equal_to => 1800, :message => "must be at least 30 minutes"}

  validate :cannot_be_in_the_past
  validate :cannot_be_during_quiet_hours
  validate :must_fill_half_hour_slot

  def cannot_be_in_the_past
    if self.when.present? && self.when < Date.today
      errors.add(:when, "can't be in the past")
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
end
