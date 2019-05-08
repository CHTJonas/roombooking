ENV['RAILS_ENV'] ||= 'test'
ENV['QUIET'] = 'true'

require_relative '../config/environment'
require 'rails/test_help'

Rails.cache.clear

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
