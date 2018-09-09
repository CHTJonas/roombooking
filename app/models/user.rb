class User < ApplicationRecord
  has_many :log_events, as: :logable, :dependent => :delete_all
  has_many :booking
  has_many :camdram_token

  # Create a User model object from an omniauth authentication object.
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end
    end
  end

  # Grants site administrator privileges to the user.
  def make_admin!
    self.admin = true
  end

  # Revokes site administrator privileges from the user.
  def revoke_admin!
    self.admin = false
  end

  # Returns the last CamdramToken object stored in the database that belongs to the user.
  def latest_camdram_token
    return CamdramToken.where(user_id: self.id).last
  end

  def authorised_camdram_shows
    venues = ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar', 'corpus-playroom'] # Holds Camdram venues we care about.
    all_shows = Array.new # Holds shows we get from Camdram API.
    shows = Array.new # Holds shows we return to the caller.
    if self.admin
      # Get all upcoming shows in venues we care about.
      venues.each { |venue| all_shows += camdram.get_venue(venue).shows }
    else
      # Get the user's upcoming shows in venues we care about.
      all_shows += camdram.user.get_shows.reject { |x| !venues.include? x.venue.slug }
    end
    all_shows.each do |show|
      # We only care about upcoming shows not shows in the past.
      if show.performances.last.end_date > Time.now
        shows << [show.name, show.id]
      end
    end
    return shows
  end

  def authorised_camdram_societies
    all_societies = Array.new # Holds societies we get from Camdram API.
    societies = Array.new# Holds societies we return to the caller.
    if self.admin
      # Admins can make bookings on behalf of any society
      all_societies += camdram.get_orgs
    else
      # Users can make bookings on behalf of societies they administer on Camdram
      all_societies += camdram.user.get_orgs
    end
    all_societies.each do |society|
      societies << [society.name, society.id]
    end
    return societies
  end

  def camdram
    @camdram ||= Camdram::Client.new do |config|
      config.api_token = latest_camdram_token.token
      config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
    end
  end

end
