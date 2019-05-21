ENV['RAILS_ENV'] ||= 'test'
ENV['QUIET'] = 'true'

require_relative '../config/environment'
require 'rails/test_help'
require 'sidekiq/testing'
require 'minitest/retry'
require 'simplecov'
require 'codecov'

Rails.cache.clear
Sidekiq::Testing.fake!
SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::Codecov

Minitest::Retry.use!(
  exceptions_to_retry: [Roombooking::CamdramAPI::CamdramError],
  retry_count: 3,
  verbose: true
)

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
