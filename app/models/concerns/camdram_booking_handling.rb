# frozen_string_literal: true

module CamdramBookingHandling
  extend ActiveSupport::Concern

  included do
    has_many :bookings, as: :camdram_model, dependent: :destroy
    validates :slack_webhook, slack_webhook: true
  end

  # Returns an array that counts the entity's currently used quota for the
  # week beginning on the given date.
  def weekly_quota(start_of_week)
    end_of_week = start_of_week + 1.week
    bookings = self.bookings.in_range(start_of_week, end_of_week)
    calculate_weekly_quota(start_of_week, bookings)
  end
end
