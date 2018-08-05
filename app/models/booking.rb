class Booking < ApplicationRecord
  belongs_to :venue
  belongs_to :user

  validates :name, presence: true
  validates :when, presence: true
  validates :duration, :numericality => {:greater_than_or_equal_to => 900, :message => "must be at least 15 minutes"}

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
