# frozen_string_literal: true

require 'dotenv/load'

if File.exist? File.expand_path('../.prod', __dir__)
  ENV['RAILS_ENV'] = 'production'
end
