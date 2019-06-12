# frozen_string_literal: true

if File.exist? File.expand_path('../.prod', __dir__)
  ENV['RAILS_ENV'] = 'production'
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Set up gems listed in the Gemfile.
require 'bundler/setup'

# Speed up boot time by caching expensive operations.
require 'bootsnap/setup' unless ENV['DISABLE_SPRING'] == 1
