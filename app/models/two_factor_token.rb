# frozen_string_literal: true

# == Schema Information
#
# Table name: two_factor_tokens
#
#  id                  :bigint(8)        not null, primary key
#  encrypted_secret    :binary
#  encrypted_secret_iv :binary
#  last_otp_at         :integer          default(0), not null
#  user_id             :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class TwoFactorToken < ApplicationRecord
  belongs_to :user

  attr_encrypted_options.merge!(encode: false, encode_iv: false,
    encode_salt: false, key: Roombooking::Crypto.secret_key)
  attr_encrypted :secret

  validates :secret, presence: true

  # Generates a new two-factor record from the passed in user model.
  def self.from_user(user)
    create!(secret: ROTP::Base32.random_base32, user: user)
  end

  # Generates a valid TOTP code for the current period, or the period with the
  # given timestamp.
  def generate(at=nil)
    if at.present?
      totp.at(at)
    else
      totp.now
    end
  end

  # Returns the timestamp of the current period if the TOTP code is valid, or
  # nil otherwise.
  def verify(code)
    period = totp.verify(code, after: self.last_otp_at, drift_behind: 15)
    self.last_otp_at = period if period
  end

  private

  def totp
    @totp ||= ROTP::TOTP.new(self.secret, issuer: "ADC Room Booking System")
  end
end
