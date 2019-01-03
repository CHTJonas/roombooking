class CamdramToken < ActiveRecord::Base
  belongs_to :user

  # Create a CamdramToken from an OmniAuth::AuthHash and a User.
  def self.create_with_credentials(creds, user)
    create! do |cdtkn|
      cdtkn.access_token = creds[:token]
      cdtkn.refresh_token = creds[:refresh_token]
      cdtkn.expires_at = creds[:expires_at]
      cdtkn.user = user
    end
  end

  # True if the Camdram API token has expired, false otherwise
  def expired?
    Time.now.to_i >= self.expires_at
  end

  # Attempts to refresh the Camdram access token and, if successful, saves and returns the new token.
  def refresh
    client = Camdram::Client.new do |config|
      token_hash = { access_token: self.access_token.to_s, refresh_token: self.refresh_token.to_s, expires_at: self.expires_at.to_i }
      app_id = Rails.application.credentials.dig(:camdram, :app_id)
      app_secret = Rails.application.credentials.dig(:camdram, :app_secret)
      config.auth_code(token_hash, app_id, app_secret)
      config.user_agent = "ADC Room Booking System/#{Roombooking::VERSION}"
      config.base_url = "https://www.camdram.net"
    end

    # As soon as we call Camdram::Client.refresh_access_token! the OAuth API
    # request to Camdram is made. This invalidates the previous token which
    # we must now delete, so there's no advantage in using a single database
    # transaction here.

    begin
      new_token = client.refresh_access_token!
    ensure
      self.destroy
    end

    CamdramToken.create! do |cdtkn|
      cdtkn.access_token = new_token[:access_token]
      cdtkn.refresh_token = new_token[:refresh_token]
      cdtkn.expires_at = new_token[:expires_at]
      cdtkn.user = self.user
    end
  end
end
