ENV['RAILS_ENV'] ||= 'test'
ENV['QUIET'] = 'true'

require_relative '../config/environment'
require 'rails/test_help'
require 'simplecov'
require 'codecov'
require 'sidekiq/testing'

Rails.cache.clear
Sidekiq::Testing.fake!
SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::Codecov

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
