# == Schema Information
#
# Table name: camdram_societies
#
#  id           :bigint(8)        not null, primary key
#  camdram_id   :bigint(8)        not null
#  max_meetings :integer          default(0), not null
#  active       :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
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
    @camdram_object ||= Roombooking::CamdramAPI.client.get_society(self.camdram_id)
  end

  # Returns the name of the society by querying the Camdram API.
  def name
    camdram_object.name
  end

  # Returns an array that counts the society's currently used quota for the
  # week beginning on the give day.
  def weekly_quota(start_of_week)
    quota = 0
    bookings = bookings_in_week(start_of_week)
    bookings.each do |booking|
      if booking.purpose == 'meeting of'
        quota += 1
      end
    end
    quota
  end

  # Gets all the society's bookings for the week beginning on the give day.
  def bookings_in_week(start_of_week)
    end_of_week = start_of_week + 1.week
    bookings_in_range(start_of_week, end_of_week)
  end

  # Gets all the society's bookings that occur between the times given.
  def bookings_in_range(start_date, end_date)
    ordinary_bookings = self.booking
      .where(repeat_mode: :none)
      .where(start_time: start_date..end_date)
    daily_repeat_bookings = self.booking
      .where(repeat_mode: :daily)
      .where(start_time: Time.at(0)..end_date)
      .where(repeat_until: start_date..DateTime::Infinity.new)
    weekly_repeat_bookings = self.booking
      .where(repeat_mode: :weekly)
      .where(start_time: Time.at(0)..end_date)
      .where(repeat_until: start_date..DateTime::Infinity.new)
    return ordinary_bookings + daily_repeat_bookings + weekly_repeat_bookings
  end
end
