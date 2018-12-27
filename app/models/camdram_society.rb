class CamdramSociety < ActiveRecord::Base
  has_many :booking, as: :camdram_model
  validates :camdram_id, numericality: { only_integer: true }
  validates :max_bookings, numericality: { only_integer: true }

  def camdram_object
    camdram.get_org(self.camdram_id)
  end

  private

  def camdram
    @camdram ||= Camdram::Client.new do |config|
      config.api_token = nil
      config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
    end
  end
end
