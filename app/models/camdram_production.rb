class CamdramProduction < ApplicationRecord
  has_many :booking, as: :camdram_model, dependent: :delete_all

  validates :camdram_id, numericality: { only_integer: true }
  validates :max_bookings, numericality: { only_integer: true }

  # Creates a CamdramProduction model from a Camdram::Show object.
  def self.create_from_camdram(show)
    create! do |prod|
      prod.camdram_id = show.id
      prod.max_bookings = 7
      prod.active = false
    end
  end

  # Returns the Camdram::Show object that the record references by querying
  # the Camdram API.
  def camdram_object
    camdram.get_show(self.camdram_id)
  end

  # Returns the name of the show by querying the Camdram API.
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
