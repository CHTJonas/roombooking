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
#  memoized_name :string
#

class CamdramSociety < ApplicationRecord
  include CamdramInteroperability
  include CamdramBookingHandling
  include DataPreservation

  has_paper_trail
  strip_attributes only: [:slack_webhook]
  uses_camdram_client_method :get_society

  has_and_belongs_to_many :users

  validates :max_meetings, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  # Creates a CamdramSociety model from a numeric Camdram ID.
  def self.create_from_id(id)
    create_from_id_and_name(id, nil)
  end

  # Creates a CamdramSociety model from a numeric Camdram ID and name.
  def self.create_from_id_and_name(id, name)
    create! do |roombooking_society|
      roombooking_society.camdram_id = id
      roombooking_society.max_meetings = 14
      roombooking_society.active = false
      roombooking_society.memoized_name = name if name.present?
    end
  end

  # Abstraction to allow vallidation of new bookings. Returns the society's
  # currently used quota for the week beginning on the given date.
  def calculate_weekly_quota(start_of_week, bookings)
    end_of_week = start_of_week + 7.days
    quota = 0
    bookings.each do |booking|
      booking.repeat_iterator do |st, _|
        break if st >= end_of_week
        if st >= start_of_week
          quota_increase = booking.duration / 60 / 60
          if booking.purpose == 'meeting_of'
            quota += quota_increase
          end
        end
      end
    end
    quota
  end

  # Returns true if the society has exceeded it's booking quota, false
  # otherwise.
  def exceeded_weekly_quota?(quota)
    quota > max_meetings
  end
end
