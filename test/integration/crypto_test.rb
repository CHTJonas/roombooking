require 'test_helper'

class CryptoTest < ActionDispatch::IntegrationTest
  test 'secure key derivation' do
    secure_bytes = Roombooking::Crypto.secret_key
    assert secure_bytes.length == 32
  end
end
