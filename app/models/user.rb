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
      CamdramProduction.where(active: true)
    else
      shows = camdram.user.get_shows.reject { |show| show.performances.last.end_date < Time.now }
      CamdramProduction.where(camdram_id: shows, active: true)
    end
  end

  def authorised_camdram_societies
    if self.admin
      CamdramSociety.where(active: true)
    else
      societies = camdram.user.get_societies
      CamdramSociety.where(camdram_id: societies, active: true)
    end
  end

  private

  def camdram
    Camdram::Client.new do |config|
      token = latest_camdram_token
      token_hash = {access_token: token.token, refresh_token: token.refresh_token, expires_at: token.expires_at}
      app_id = Rails.application.credentials.dig(:camdram, :app_id)
      app_secret = Rails.application.credentials.dig(:camdram, :app_secret)
      config.auth_code(token_hash, app_id, app_secret)
      config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
      config.base_url = "https://www.camdram.net"
    end
  end

end
