# frozen_string_literal: true

class CamdramEntity < ApplicationRecord
  self.abstract_class = true

  has_many :booking, as: :camdram_model, dependent: :destroy
  has_many :approved_bookings, -> { where(approved: true) },
    class_name: 'Booking', as: :camdram_model

  validates :camdram_id, numericality: { only_integer: true,
    greater_than: 0 }, uniqueness: { message: 'entity already exists' }
  validates :slack_webhook, slack_webhook: true

  # Creates a CamdramEntity model from a Camdram::Base object.
  def self.create_from_camdram(camdram_base)
    create_from_id(camdram_base.id)
  end

  # Find a CamdramEntity model from a Camdram::Base object.
  def self.find_from_camdram(camdram_base)
    find_by(camdram_id: camdram_base.id)
  end

  # Returns the name of the entity by querying the Camdram API.
  def name
    camdram_object.name
  end

  # Returns the entity's external URL on Camdram.
  def url
    Roombooking::CamdramAPI.url_for(camdram_object)
  end

  # Returns an array that counts the entity's currently used quota for the
  # week beginning on the given date.
  def weekly_quota(start_of_week)
    end_of_week = start_of_week + 1.week
    bookings = self.booking.in_range(start_of_week, end_of_week)
    calculate_weekly_quota(start_of_week, bookings)
  end
end
