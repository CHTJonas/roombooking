# frozen_string_literal: true

module DataPreservation
  extend ActiveSupport::Concern

  included do
    before_destroy :can_destroy?, prepend: true
  end

  def can_destroy?
    unless bookings.count == 0 || ENV['LET_ME_DESTROY_ROOMS'] == "YES_I_WANT_TO_LOSE_BOOKING_DATA"
      self.errors.add(:base, "#{name} can't be destroyed because the system is configured to prevent the loss of booking data.")
      throw :abort
    end
  end
end
