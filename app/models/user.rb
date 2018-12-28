class User < ApplicationRecord
  has_many :log_events, as: :logable, :dependent => :delete_all
  has_many :provider_account
  has_many :camdram_token
  has_many :booking

  # Create a User model object from an omniauth authentication object.
  def self.create_with_provider(auth)
    ActiveRecord::Base.transaction do
      u = User.new
      u.name = auth['info']['name'] || ""
      u.email = auth['info']['email'] || ""
      u.save
      pa = ProviderAccount.new
      pa.provider = auth['provider']
      pa.uid = auth['uid']
      pa.user_id = u.id
      pa.save
      u
    end
  end

  # Grants site administrator privileges to the user.
  def make_admin!
    self.admin = true
    self.save
  end

  # Revokes site administrator privileges from the user.
  def revoke_admin!
    self.admin = false
    self.save
  end

  # Returns the last CamdramToken object stored in the database that belongs to the user.
  def latest_camdram_token
    return CamdramToken.where(user_id: self.id).last
  end

  def authorised_camdram_shows
    if self.admin
      CamdramProduction.all
    else
      shows = camdram.user.get_shows.reject { |show| show.performances.last.end_date < Time.now }
      CamdramProduction.where(camdram_id: shows)
    end
  end

  def authorised_camdram_societies
    if self.admin
      CamdramSociety.all
    else
      societies = camdram.user.get_orgs
      CamdramSociety.where(camdram_id: societies)
    end
  end

  private

  def camdram
    @camdram ||= Camdram::Client.new do |config|
      config.api_token = latest_camdram_token.token
      config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
    end
  end

end
