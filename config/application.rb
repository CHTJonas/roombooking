# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems limited to the test,
# development, or production groups.
Bundler.require(*Rails.groups)

module Roombooking
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Use Redis for caching and report exceptions to Sentry as warnings.
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_CACHE'], error_handler: lambda do |params|
        exception = params[:exception]
        method = params[:method]
        returning = params[:returning]
        Raven.capture_exception exception, level: 'warning',
          tags: { method: method, returning: returning }
      end, driver: :hiredis
    }

    if OS::Underlying.docker? && Rails.env.development?
      config.web_console.whitelisted_ips = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16']
    end

    config.time_zone = 'UTC'
    config.beginning_of_week = :sunday

    config.autoloader = :zeitwerk
    config.autoload_paths << Rails.root.join('lib')

    require 'roombooking/middleware/header_inserter'
    config.middleware.insert_after Rack::Sendfile, Roombooking::Middleware::HeaderInserter
  end
end
