# frozen_string_literal: true

# == Schema Information
#
# Table name: two_factor_tokens
#
#  id                  :bigint(8)        not null, primary key
#  encrypted_secret    :binary
#  encrypted_secret_iv :binary
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

  def self.from_user(user)
    create!(secret: ROTP::Base32.random_base32, user: user)
  end

  def generate
    totp.now
  end

  def verify(code)
    totp.verify(code)
  end

  def totp
    @totp ||= ROTP::TOTP.new(self.secret, issuer: "ADC Room Booking System")
  end
end
