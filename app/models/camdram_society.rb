class CamdramSociety < ActiveRecord::Base
  has_many :booking, as: :camdram_model
  validates :camdram_id, numericality: { only_integer: true }
  validates :max_bookings, numericality: { only_integer: true }

  # Creates a CamdramSociety model from a Camdram::Organisation object.
  def self.create_from_camdram(org)
    create! do |soc|
      soc.camdram_id = org.id
      soc.max_bookings = 7
      soc.active = false
    end
  end

  # Returns the Camdram::Organisation object that the record references by querying the Camdram API.
  def camdram_object
    camdram.get_org(self.camdram_id)
  end

  # Returns the name of the society by querying the Camdram API.
  def name
    camdram_object.name
  end

  private

  def camdram
    @camdram ||= Camdram::Client.new do |config|
      config.api_token = nil
      config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
    end
  end
end
