# frozen_string_literal: true

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
#  dormant        :boolean          default(FALSE), not null
#  slack_webhook  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class CamdramShow < CamdramEntity
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

  # Returns the Camdram::Show object that the record references by querying
  # the Camdram API.
  def camdram_object
    @camdram_object ||= Roombooking::CamdramAPI.with { |client| client.get_show(self.camdram_id) }
  end

  # Abstraction to allow vallidation of new bookings. Returns an array that
  # counts the show's currently used quota for the week beginning on the
  # given date.
  def calculate_weekly_quota(start_of_week, bookings)
    quota = [0, 0, 0] # [rehearsals, auditions, meetings]
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

  # Returns true if the show has exceeded any of the given quotas,
  # false otherwise.
  def exceeded_weekly_quota?(quota)
    quota[0] > self.max_rehearsals ||
      quota[1] > self.max_auditions ||
      quota[2] > self.max_meetings
  end
end
