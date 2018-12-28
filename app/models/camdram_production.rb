class CamdramProduction < ActiveRecord::Base
  has_many :booking, as: :camdram_model
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

  # Returns the Camdram::Show object that the record references by querying the Camdram API.
  def camdram_object
    camdram.get_show(self.camdram_id)
  end

  # Returns the name of the show by querying the Camdram API.
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
