# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Roombooking
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Use Redis for caching.
    config.cache_store = :redis_cache_store, {
      url: Rails.application.credentials.dig(:redis, :cache_url),
      error_handler: -> (method:, returning:, exception:) {
        # Report errors to Sentry as warnings
        Raven.capture_exception exception, level: 'warning',
          tags: { method: method, returning: returning }
      }
    }

    config.time_zone = 'London'
    config.beginning_of_week = :sunday
    config.eager_load_paths << Rails.root.join('lib')
    config.action_mailer.default_url_options = { host: 'roombooking-dev.adctheatre.com' }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
