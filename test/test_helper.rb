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
  exceptions_to_retry: [Roombooking::CamdramAPI::ServerError, Roombooking::CamdramAPI::TimeoutError],
  retry_count: 3,
  verbose: true
)

Minitest::Retry.on_retry do |klass, test_name, retry_count|
  # Retry with an exponential backoff.
  sleep 3 ** ((retry_count + 1) / 2.0)
end

class ActiveSupport::TestCase
  fixtures :all
end
