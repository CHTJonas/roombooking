# frozen_string_literal: true

# == Schema Information
#
# Table name: camdram_societies
#
#  id            :bigint           not null, primary key
#  camdram_id    :bigint           not null
#  max_meetings  :integer          default(0), not null
#  active        :boolean          default(FALSE), not null
#  slack_webhook :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CamdramSociety < CamdramEntity
  validates :max_meetings, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  # Creates a CamdramSociety model from a numeric Camdram id.
  def self.create_from_id(id)
    create! do |roombooking_society|
      roombooking_society.camdram_id = id
      roombooking_society.max_meetings = 14
      roombooking_society.active = false
    end
  end

  # Returns the Camdram::Organisation object that the record references by
  # querying the Camdram API.
  def camdram_object
    @camdram_object ||= Roombooking::CamdramAPI.with { |client| client.get_society(self.camdram_id).make_orphan }
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
