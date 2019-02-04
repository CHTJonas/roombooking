# == Schema Information
#
# Table name: camdram_societies
#
#  id            :bigint(8)        not null, primary key
#  camdram_id    :bigint(8)        not null
#  max_meetings  :integer          default(0), not null
#  active        :boolean          default(FALSE), not null
#  slack_webhook :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CamdramSociety < ApplicationRecord
  has_many :booking, as: :camdram_model, dependent: :delete_all
  has_many :approved_bookings, -> { where(approved: true) },
    class_name: 'Booking', as: :camdram_model

  validates :camdram_id, numericality: {
    only_integer: true,
    greater_than: 0 }
  validates :max_meetings, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  # Creates a CamdramSociety model from a Camdram::Organisation object.
  def self.create_from_camdram(camdram_society)
    create_from_id(camdram_society.id)
  end

  # Creates a CamdramSociety model from a numeric Camdram id.
  def self.create_from_id(id)
    create! do |roombooking_society|
      roombooking_society.camdram_id = id
      roombooking_society.max_meetings = 14
      roombooking_society.active = false
    end
  end

  # Find a CamdramSociety model from a Camdram::Organisation object.
  def self.find_from_camdram(camdram_society)
    find_by(camdram_id: camdram_society.id)
  end

  # Returns the Camdram::Organisation object that the record references by
  # querying the Camdram API.
  def camdram_object
    @camdram_object ||= Roombooking::CamdramAPI.with { |client| client.get_society(self.camdram_id) }
  end

  # Returns the name of the society by querying the Camdram API.
  def name
    camdram_object.name
  end

  # Returns an array that counts the society's currently used quota for the
  # week beginning on the given date.
  def weekly_quota(start_of_week)
    end_of_week = start_of_week + 1.week
    bookings = self.booking.in_range(start_of_week, end_of_week)
    calculate_weekly_quota(start_of_week, bookings)
  end

  # Abstraction to allow vallidation of new bookings. Returns the society's
  # currently used quota for the week beginning on the given date.
  def calculate_weekly_quota(start_of_week, bookings)
    quota = 0
    bookings.each do |booking|
      occurrences = 1
      if booking.repeat_mode == 'daily'
        start_repeating_from = start_of_week < booking.start_time ? booking.start_time : start_of_week
        occurrences = (start_repeating_from.to_date..booking.repeat_until.to_date).count
      end
      quota_increase = occurrences * booking.duration / 60 / 60
      if booking.purpose == 'meeting_of'
        quota += quota_increase
      end
    end
    quota
  end

  # Returns true if the society has exceeded it's booking quota, false
  # otherwise.
  def exceeded_weekly_quota?(quota)
    quota > self.max_meetings
  end
end
