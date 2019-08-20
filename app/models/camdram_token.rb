# frozen_string_literal: true

# == Schema Information
#
# Table name: camdram_tokens
#
#  id                         :bigint           not null, primary key
#  expires_at                 :datetime         not null
#  user_id                    :bigint           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  encrypted_access_token     :binary           not null
#  encrypted_access_token_iv  :binary           not null
#  encrypted_refresh_token    :binary           not null
#  encrypted_refresh_token_iv :binary           not null
#

class CamdramToken < ApplicationRecord
  belongs_to :user

  attr_encrypted_options.merge!(encode: false, encode_iv: false,
    encode_salt: false, key: Roombooking::Crypto.secret_key)
  attr_encrypted :access_token
  attr_encrypted :refresh_token

  validates :expires_at, presence: true

  # These are tokens that have expired so long ago that they can't be renewed.
  scope :dead, -> { where 'expires_at <= ?', DateTime.now - 1.hour }

  # These are tokens that have expired or are expiring soon, but can be renewed.
  scope :expiring_soon, -> { where expires_at: (DateTime.now - 1.hour)..(DateTime.now + 5.minutes) }

  # Returns a CamdramToken from an OmniAuth::AuthHash and a user.
  def self.from_omniauth_and_user(auth_hash, user)
    credentials = auth_hash['credentials']
    access_token = credentials[:token]
    refresh_token = credentials[:refresh_token]
    expires_at = Time.at(credentials[:expires_at])
    create!(access_token: access_token, refresh_token: refresh_token,
      expires_at: expires_at, user: user)
  end

  # True if the Camdram API token has expired, false otherwise.
  def expired?
    DateTime.now >= self.expires_at
  end

  # True if the token can be refreshed, false otherwise.
  def refreshable?
    DateTime.now < self.expires_at + 1.hour
  end

  # Attempts to refresh the Camdram access token and, if successful, saves and
  # returns the new token. Note that there's no point in caching data here as
  # the only requests made are for new access tokens.
  def refresh
    client = Camdram::Client.new do |config|
      token_hash = { access_token: self.access_token.to_s,
        refresh_token: self.refresh_token.to_s,
        expires_at: self.expires_at.to_i }
      app_id = ENV['CAMDRAM_APP_ID']
      app_secret = ENV['CAMDRAM_APP_SECRET']
      config.auth_code(token_hash, app_id, app_secret)
      config.user_agent = "ADC Room Booking System/#{Roombooking::Version}"
      config.base_url = "https://www.camdram.net"
    end

    # As soon as we call Camdram::Client.refresh_access_token! the OAuth API
    # request to Camdram is made. This invalidates the previous token which
    # we must now delete, so there's no advantage in using a single database
    # transaction here.

    begin
      new_token = client.refresh_access_token!
    rescue Exception => e
      raise Roombooking::CamdramApi::CamdramError.new, e
    ensure
      self.destroy
    end

    CamdramToken.create! do |cdtkn|
      cdtkn.access_token = new_token[:access_token]
      cdtkn.refresh_token = new_token[:refresh_token]
      cdtkn.expires_at = Time.at(new_token[:expires_at])
      cdtkn.user = self.user
    end
  end
end
