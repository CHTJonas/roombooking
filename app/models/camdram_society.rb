class CamdramSociety < ApplicationRecord
  has_many :booking, as: :camdram_model, dependent: :delete_all

  validates :camdram_id, numericality: { only_integer: true }
  validates :max_meetings, numericality: { only_integer: true }

  # Creates a CamdramSociety model from a Camdram::Organisation object.
  def self.create_from_camdram(org)
    create! do |soc|
      soc.camdram_id = org.id
      soc.max_bookings = 7
      soc.active = false
    end
  end

  # Returns the Camdram::Organisation object that the record references by
  # querying the Camdram API.
  def camdram_object
    @camdram_object ||= camdram.get_society(self.camdram_id)
  end

  # Returns the name of the society by querying the Camdram API.
  def name
    camdram_object.name
  end

  private

  # Private method to return the application-wide Camdram API client from the
  # Rails config.
  def camdram
    Rails.application.config.camdram_client_pool.checkout
  end
end
