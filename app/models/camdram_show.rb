# == Schema Information
#
# Table name: camdram_shows
#
#  id             :bigint(8)        not null, primary key
#  camdram_id     :bigint(8)        not null
#  max_rehearsals :integer          default(0), not null
#  max_auditions  :integer          default(0), not null
#  max_meetings   :integer          default(0), not null
#  active         :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class CamdramShow < ApplicationRecord
  has_many :booking, as: :camdram_model, dependent: :delete_all
  has_many :approved_bookings, -> { where(approved: true) },
    class_name: 'Booking', as: :camdram_model

  validates :camdram_id, numericality: {
    only_integer: true,
    greater_than: 0
  }
  validates :max_rehearsals, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :max_auditions, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :max_meetings, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  # Creates a CamdramShow model from a Camdram::Show object.
  def self.create_from_camdram(camdram_show)
    create_from_id(camdram_show.id)
  end

  # Creates a CamdramShow model from a numeric Camdram id.
  def self.create_from_id(id)
    create! do |roombooking_show|
      roombooking_show.camdram_id = id
      roombooking_show.max_rehearsals = 12
      roombooking_show.max_auditions = 10
      roombooking_show.max_meetings = 4
      roombooking_show.active = false
    end
  end

  # Find a CamdramShow model from a Camdram::Show object.
  def self.find_from_camdram(camdram_show)
    find_by(camdram_id: camdram_show.id)
  end

  # Returns the Camdram::Show object that the record references by querying
  # the Camdram API.
  def camdram_object
    @camdram_object ||= Roombooking::CamdramAPI.client.get_show(self.camdram_id)
  end

  # Returns the name of the show by querying the Camdram API.
  def name
    camdram_object.name
  end

  # Returns an array that counts the show's currently used quota for the
  # week beginning on the give day.
  def weekly_quota(start_of_week)
    quota = [0, 0, 0] # [rehearsals, auditions, meetings]
    bookings = bookings_in_week(start_of_week)
    bookings.each do |booking|
      if booking.purpose == 'rehearsal of'
        quota[0] += 1
      elsif booking.purpose == 'audition for'
        quota[1] += 1
      elsif booking.purpose == 'meeting for'
        quota[2] += 1
      end
    end
    quota
  end

  # Gets all the show's bookings for the week beginning on the give day.
  def bookings_in_week(start_of_week)
    end_of_week = start_of_week + 1.week
    bookings_in_range(start_of_week, end_of_week)
  end

  # Gets all the show's bookings that occur between the times given.
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
