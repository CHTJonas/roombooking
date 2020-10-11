# frozen_string_literal: true

module Roombooking
  module Crypto
    class << self
      # Returns a binary sequence of 32 bytes in length that is derived
      # from Rails' secret key base. This is suitable for use with the
      # aes-256-gcm encryption algorithm of the attr_encrypted gem.
      def secret_key
        key = ENV['SECRET_KEY_BASE']
        arr = [key]
        arr.pack('H64')
      end
    end
  end
end
