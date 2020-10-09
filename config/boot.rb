# frozen_string_literal: true

require_relative 'prod'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Set up gems listed in the Gemfile.
require 'bundler/setup'

# Speed up boot time by caching expensive operations.
require 'bootsnap/setup' unless ENV['DISABLE_SPRING'] == 1
