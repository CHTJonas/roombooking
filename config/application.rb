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
        Sentry.with_scope do |scope|
          scope.set_tags(method: params[:method])
          scope.set_tags(returning: params[:returning])
          Sentry.capture_exception(params[:exception], level: 'warning')
        end
      end, driver: :hiredis
    }

    if OS::Underlying.docker? && Rails.env.development?
      config.web_console.whitelisted_ips = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16']
    end

    config.time_zone = 'UTC'
    config.beginning_of_week = :sunday

    config.autoloader = :zeitwerk
    config.autoload_paths << Rails.root.join('lib')
  end
end
