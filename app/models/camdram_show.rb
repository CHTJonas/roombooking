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
  # week beginning on the give date.
  def weekly_quota(start_of_week)
    quota = [0, 0, 0] # [rehearsals, auditions, meetings]
    bookings = bookings_in_week(start_of_week)
    bookings.each do |booking|
      occurrences = 1
      if booking.repeat_mode == 'daily'
        start_repeating_from = start_of_week < booking.start_time ? booking.start_time : start_of_week
        occurrences = (start_repeating_from.to_date..booking.repeat_until.to_date).count
      end
      quota_increase = occurrences * booking.duration / 60 / 60
      if booking.purpose == 'rehearsal_for'
        quota[0] += quota_increase
      elsif booking.purpose == 'audition_for'
        quota[1] += quota_increase
      elsif booking.purpose == 'meeting_for'
        quota[2] += quota_increase
      end
    end
    quota
  end

  # Gets all the show's bookings for the week beginning on the give date.
  def bookings_in_week(start_of_week)
    end_of_week = start_of_week + 1.week
    self.booking.in_range(start_of_week, end_of_week)
  end
end
