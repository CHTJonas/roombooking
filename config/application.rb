# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems limited to the test,
# development, or production groups.
Bundler.require(*Rails.groups)

module Roombooking
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Use Redis for caching and report exceptions to Sentry as warnings.
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_CACHE'], error_handler: lambda do |params|
        exception = params[:exception]
        method = params[:method]
        returning = params[:returning]
        Raven.capture_exception exception, level: 'warning',
          tags: { method: method, returning: returning }
      end
    }

    if OS::Underlying.docker? && Rails.env.development?
      config.web_console.whitelisted_ips = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16']
    end

    config.time_zone = 'London'
    config.beginning_of_week = :sunday
    config.eager_load_paths << Rails.root.join('lib')
    config.action_mailer.default_url_options = { host: 'roombooking-dev.adctheatre.com' }

    mail_log_file = Rails.root.join('log', "roombooking_#{Rails.env}_mail.log")
    Yell['mail'] = Yell.new do |l|
      l.adapter(:datefile, mail_log_file, keep: 31, level: 'gte.info')
    end
    config.action_mailer.logger = Yell['mail']
  end
end
