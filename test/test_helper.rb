ENV['RAILS_ENV'] ||= 'test'
ENV['QUIET'] = 'true'

require 'simplecov'
SimpleCov.start 'rails'

require_relative '../config/environment'
require 'rails/test_help'
Rails.application.eager_load!
Rails.cache.clear

require 'sidekiq/testing'
Sidekiq::Testing.fake!

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'minitest/retry'
Minitest::Retry.use!(
  exceptions_to_retry: [Roombooking::CamdramAPI::CamdramError, Roombooking::CamdramAPI::ClientError, Roombooking::CamdramAPI::ServerError, Roombooking::CamdramAPI::TimeoutError],
  retry_count: 3,
  verbose: true
)

class ActiveSupport::TestCase
  fixtures :all
end
