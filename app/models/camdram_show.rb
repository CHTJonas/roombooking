class CamdramShow < ApplicationRecord
  has_many :booking, as: :camdram_model, dependent: :delete_all

  validates :camdram_id, numericality: { only_integer: true }
  validates :max_rehearsals, numericality: { only_integer: true }
  validates :max_auditions, numericality: { only_integer: true }
  validates :max_meetings, numericality: { only_integer: true }

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
    @camdram_object ||= camdram.get_show(self.camdram_id)
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
