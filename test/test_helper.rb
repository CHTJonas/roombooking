ENV['RAILS_ENV'] ||= 'test'
ENV['QUIET'] = 'true'

require 'dotenv/load'

if ENV['CODECOV_TOKEN'].present?
  require 'simplecov'
  require 'codecov'
  SimpleCov.start 'rails'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require_relative '../config/environment'
require 'rails/test_help'
Rails.application.eager_load!
Rails.cache.clear

require 'sidekiq/testing'
Sidekiq::Testing.fake!

require 'minitest/retry'
Minitest::Retry.use!(
  exceptions_to_retry: [Camdram::Error::ServerError, Camdram::Error::Timeout],
  retry_count:         5,
  verbose:             true
)

Minitest::Retry.on_retry do |klass, test_name, retry_count, _result|
  # Retry with an exponential backoff.
  timer = (3**((retry_count + 1) / 2.0) + 2).ceil
  puts ''
  puts "Encountered #{klass} during #{test_name} for the #{retry_count.ordinalize} time"
  puts "Retrying after #{timer} seconds"
  sleep timer
end

class ActiveSupport::TestCase
  fixtures :all

  OmniAuth.config.test_mode = true

  def sign_in_user
    fake_token = { token: 'faketoken', refresh_token: 'faketoken', expires_at: Time.zone.now + 1.hour }
    OmniAuth.config.add_mock(:camdram, uid: '1234', credentials: fake_token)
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:camdram]
    get auth_callback_path(:camdram)
  end

  def sign_in_admin
    fake_token = { token: 'faketoken', refresh_token: 'faketoken', expires_at: Time.zone.now + 1.hour }
    OmniAuth.config.add_mock(:camdram, uid: '3807', credentials: fake_token)
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:camdram]
    get auth_callback_path(:camdram)
  end
end
