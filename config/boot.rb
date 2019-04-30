# frozen_string_literal: true

if File.exist? File.expand_path('../.prod', __dir__)
  ENV['RAILS_ENV'] = 'production'
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
