require 'test_helper'

class CamdramTokenTest < ActiveSupport::TestCase
  test 'should not save Camdram token without user' do
    token = CamdramToken.new(expires_at: Time.zone.now + 1.hour)
    assert_not token.save
  end

  test 'should not save Camdram token without expiry time' do
    token = CamdramToken.new(user: User.first)
    assert_not token.save
  end

  test 'should encrypt access token' do
    token = CamdramToken.new
    token.access_token = SecureRandom.alphanumeric(32)
    assert token.encrypted_access_token.present?
    assert token.encrypted_access_token_iv.present?
  end

  test 'should encrypt refresh token' do
    token = CamdramToken.new
    token.refresh_token = SecureRandom.alphanumeric(32)
    assert token.encrypted_refresh_token.present?
    assert token.encrypted_refresh_token_iv.present?
  end

  test 'should expire if expiry time is in past' do
    token1 = CamdramToken.new(expires_at: Time.zone.now - 3.hours)
    token2 = CamdramToken.new(expires_at: Time.zone.now + 3.hours)
    assert token1.expired?
    assert_not token2.expired?
  end

  test 'should be refreshable if expiry time is less than one hour in the past' do
    token1 = CamdramToken.new(expires_at: Time.zone.now + 1.hour)
    token2 = CamdramToken.new(expires_at: Time.zone.now)
    token3 = CamdramToken.new(expires_at: Time.zone.now - 1.hour)
    assert token1.refreshable?
    assert token2.refreshable?
    assert_not token3.refreshable?
  end
end
